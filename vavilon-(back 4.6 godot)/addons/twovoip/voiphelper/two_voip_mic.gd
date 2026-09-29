extends Node

var opusencoder : TwovoipOpusEncoder = TwovoipOpusEncoder.new()
var chunkprefix : PackedByteArray = PackedByteArray([0,0]) 

var lead_time : float = 0.15
var hang_time : float  = 0.7
var vox_threshhold = 0.05
var currentlytalking = false
var opusframecount = 0
var opusstreamcount = 0

var hangframes = 25
var hangframescountup = 0
var chunkmaxpersist = 0.0

var audiosampleframetextureimage : Image
var audiosampleframetexture : ImageTexture
var audiosampleframematerial = null

signal transmit_audio_json_packet(audiostreampacketheader : Dictionary)
signal transmit_audio_packet(opuspacket : PackedByteArray)
var json_packets_as_binary : bool = false

const rootmeansquaremaxmeasurement = false

var microphoneaudiosamplescountSeconds = 0.0
var microphoneaudiosamplescount = 0
var microphoneaudiosamplescountSecondsSampleWindow = 10.0
var automatic_gain = false

var talkingtimestart = 0
var opus_chunk_size = 960
var audio_chunk_size = 882
var frametimesecs = 0.02
var opussamplerate = 48000
var opuschannels = 2

# --- буфер компенсации задержки VOX (lead_time) ---
# Храним последние закодированные, но ещё не отправленные пакеты, пока
# currentlytalking == false. Как только VOX срабатывает, они "довыгружаются"
# первыми, чтобы не терять начало фразы.
var _lead_buffer: Array = []
var _lead_frames_cap: int = 1
func set_opus_values(p_opussamplerate, p_opusframedurationms, p_channels, p_opusbitrate, p_opuscomplexity, p_opusoptimizeforvoice):
	processtalkstreamends(false)
	assert (not currentlytalking)

	opussamplerate = p_opussamplerate
	opuschannels = p_channels
	opus_chunk_size = int(opussamplerate*p_opusframedurationms/1000.0)
	opusencoder.create_sampler(AudioServer.get_input_mix_rate(), opussamplerate, opuschannels, denoisebutton.button_pressed, opus_chunk_size)
	opusencoder.create_opus_encoder(p_opusbitrate, p_opuscomplexity, p_opusoptimizeforvoice)
	audio_chunk_size = opusencoder.get_required_input_chunk_size()
	frametimesecs = p_opusframedurationms/1000.0
	_lead_frames_cap = max(1, int(ceil(lead_time / frametimesecs)))
	if audiosampleframematerial:
		var audiosampleframedata = PackedVector2Array()
		audiosampleframedata.resize(audio_chunk_size)
		for j in range(audio_chunk_size):
			audiosampleframedata.set(j, Vector2(-0.5,0.9) if (j%10)<5 else Vector2(0.6,0.1))
		audiosampleframetextureimage = Image.create_from_data(audio_chunk_size, 1, false, Image.FORMAT_RGF, audiosampleframedata.to_byte_array())
		audiosampleframetexture = ImageTexture.create_from_image(audiosampleframetextureimage)
		audiosampleframematerial.set_shader_parameter("chunktexture", audiosampleframetexture)

var miconbutton: Button = null
var optioninputdevice: OptionButton = null
var pttbutton: Button = null
var voxbutton: Button = null
var denoisebutton: Button = null

func _ready():
	set_process(false)

func _on_miconbutton(toggled_on):
	if toggled_on:
		if OS.get_name() == "Android" and not OS.request_permission("android.permission.RECORD_AUDIO"):
			print("Waiting for user response after requesting audio permissions")
			# Must enable Record Audio permission in on Android
			@warning_ignore("untyped_declaration")
			var x = await get_tree().on_request_permissions_result
			var permission: String = x[0]
			var granted: bool = x[1]
			assert(permission == "android.permission.RECORD_AUDIO")
			print("Android Audio permission granted ", granted)

		var err = AudioServer.set_input_device_active(true)
		if err != OK:
			print("Mic input err: ", err)
			miconbutton.set_pressed_no_signal(false)
	else:
		AudioServer.set_input_device_active(false)

func _on_optioninputdevice(index: int) -> void:
	var micwason = miconbutton.button_down
	if micwason:
		miconbutton.set_pressed(false)
	var input_device: String = optioninputdevice.get_item_text(index)
	print("Set input device: ", input_device)
	AudioServer.set_input_device(input_device)
	if micwason:
		miconbutton.set_pressed(true)

func _on_vox_toggled(toggled_on):
	pttbutton.toggle_mode = toggled_on
	pttbutton.set_pressed(false)

func init_voip_mic(p_json_packets_as_binary: bool,
				   p_miconbutton: Button, 
				   p_optioninputdevice: OptionButton, 
				   p_pttbutton: Button,
				   p_voxbutton: Button, 
				   p_denoisebutton: Button, 
				   p_audiosampleframematerial: Material):
	json_packets_as_binary = p_json_packets_as_binary
	miconbutton = p_miconbutton
	if miconbutton == null:
		miconbutton = Button.new()
		miconbutton.toggle_mode = true
		miconbutton.button_pressed = true
	assert(miconbutton.toggle_mode, "MicOn must be a toggle button")
	miconbutton.connect("toggled", _on_miconbutton)
	_on_miconbutton(miconbutton.button_pressed)

	pttbutton = (p_pttbutton if p_pttbutton else Button.new())

	voxbutton = p_voxbutton
	if voxbutton == null:
		voxbutton = Button.new()
		voxbutton.toggle_mode = true
		voxbutton.button_pressed = true
	assert(voxbutton.toggle_mode, "Vox must be a toggle button")
	voxbutton.connect("toggled", _on_vox_toggled)
	_on_vox_toggled(voxbutton.button_pressed)

	denoisebutton = p_denoisebutton
	if denoisebutton == null:
		denoisebutton = Button.new()
		denoisebutton.toggle_mode = true
	assert(denoisebutton.toggle_mode, "Denoise must be a toggle button")

	audiosampleframematerial = p_audiosampleframematerial
	
	optioninputdevice = p_optioninputdevice if p_optioninputdevice else OptionButton.new()
	assert(optioninputdevice.item_count == 0)
	for d in AudioServer.get_input_device_list():
		optioninputdevice.add_item(d)
	assert(optioninputdevice.get_item_text(optioninputdevice.selected) == "Default")
	optioninputdevice.connect("item_selected", _on_optioninputdevice)

	set_process(true)

func processtalkstreamends(talking: bool):
	if talking and not currentlytalking:
		talkingtimestart = Time.get_ticks_msec()*0.001
		var leadframes = lead_time/frametimesecs
		hangframes = int(hang_time/frametimesecs)
		prints("leadframes ", leadframes, "hangframes", hangframes)

		# Компенсация задержки VOX: в _lead_buffer уже лежат закодированные
		# кадры, накопленные ДО того, как громкость превысила порог.
		# Сдвигаем время начала фразы назад на их количество, чтобы получатель
		# видел непрерывный поток без разрыва.
		var lead_count := _lead_buffer.size()
		talkingtimestart -= lead_count * frametimesecs

		var audiostreampacketheader = { 
			"opusframesize":opus_chunk_size, 
			"opussamplerate":opussamplerate, 
			"opuschannels":opuschannels,
			"lenchunkprefix":len(chunkprefix), 
			"opusstreamcount":opusstreamcount, 
			"opusframecount":0,
			"talkingtimestart":talkingtimestart
		}
		opusencoder.reset_opus_encoder()
		if json_packets_as_binary:
			transmit_audio_packet.emit(JSON.stringify(audiostreampacketheader).to_ascii_buffer())
		else:
			transmit_audio_json_packet.emit(audiostreampacketheader)
		#get_parent().PlayerConnections.peerconnections_possiblymissingaudioheaders.clear()
		opusframecount = 0
		currentlytalking = true

		# Довыгружаем накопленный буфер — это и есть "начало фразы",
		# которое раньше терялось из-за задержки срабатывания VOX.
		for buffered_packet in _lead_buffer:
			_stamp_and_emit(buffered_packet)
		_lead_buffer.clear()

	elif not talking and currentlytalking:
		currentlytalking = false
		var talkingtimeend = Time.get_ticks_msec()*0.001
		var talkingtimeduration = talkingtimeend - talkingtimestart
		var audiopacketstreamfooter = {
			"opusstreamcount":opusstreamcount, 
			"opusframecount":opusframecount,
			"talkingtimeduration":talkingtimeduration,
			"talkingtimeend":talkingtimeend 
		}
		print("My voice chunktime=", talkingtimeduration/opusframecount, " over ", talkingtimeduration, " seconds")
		if json_packets_as_binary:
			transmit_audio_packet.emit(JSON.stringify(audiopacketstreamfooter).to_ascii_buffer())
		else:
			transmit_audio_json_packet.emit(audiopacketstreamfooter)
		opusstreamcount += 1

func request_audio_json_packet_mid_header():
	if not currentlytalking:
		return null
	var audiostreampacketmidheader = { 
			"opusframesize":opus_chunk_size, 
			"opussamplerate":opussamplerate, 
			"opuschannels":opuschannels,
			"lenchunkprefix":len(chunkprefix), 
			"opusstreamcount":opusstreamcount, 
			"opusframecount":opusframecount-1,
			"talkingtimestart":talkingtimestart
		}
	if json_packets_as_binary:
		return JSON.stringify(audiostreampacketmidheader).to_ascii_buffer()
	else:
		return audiostreampacketmidheader

func set_vox_threshhold(p_vox_threshhold):
	vox_threshhold = p_vox_threshhold
	if audiosampleframematerial:
		audiosampleframematerial.set_shader_parameter("voxthreshhold", vox_threshhold)

func set_gain(gain):
	opusencoder.set_gain(gain)

func get_gain():
	return opusencoder.get_gain()

func set_automatic_gain(enabled):
	var error = opusencoder.set_automatic_gain(enabled)
	automatic_gain = opusencoder.get_automatic_gain()
	return error

func processvox(chunkmax, audio_chunk):
	if audiosampleframematerial:
		if denoisebutton.button_pressed:
			audiosampleframematerial.set_shader_parameter("speechnoiseprobability", chunkmax)
		audiosampleframematerial.set_shader_parameter("chunkmax", chunkmax)

	if chunkmax >= vox_threshhold:
		if voxbutton.button_pressed and not pttbutton.button_pressed:
			pttbutton.button_pressed = true
		hangframescountup = 0
		if chunkmax > chunkmaxpersist:
			chunkmaxpersist = chunkmax
			if audiosampleframematerial:
				audiosampleframematerial.set_shader_parameter("chunkmaxpersist", chunkmaxpersist)
	else:
		if hangframescountup == hangframes:
			if voxbutton.button_pressed:
				pttbutton.button_pressed = false
			chunkmaxpersist = 0.0
			if audiosampleframematerial:
				audiosampleframematerial.set_shader_parameter("chunkmaxpersist", chunkmaxpersist)
		hangframescountup += 1

	if audiosampleframematerial:
		if pttbutton.button_pressed:
			audiosampleframematerial.set_shader_parameter("chunktexenabled", true)
			audiosampleframetextureimage.set_data(audio_chunk_size, 1, false, Image.FORMAT_RGF, audio_chunk.to_byte_array())
			audiosampleframetexture.update(audiosampleframetextureimage)
		else:
			audiosampleframematerial.set_shader_parameter("chunktexenabled", false)

## Кодирует текущий обработанный чанк в opus-пакет с пустым (нулевым)
## префиксом. Правильные номера кадров проставляются позже, в _stamp_and_emit,
## — так один и тот же код кодирования годится и для "живых" кадров,
## и для кадров, которые пока лежат в _lead_buffer.
func _encode_chunk_raw() -> PackedByteArray:
	if len(chunkprefix) == 2:
		return opusencoder.encode_chunk(PackedByteArray([0, 0]))
	else:
		assert (len(chunkprefix) == 0)
		return opusencoder.encode_chunk(chunkprefix)


func _stamp_and_emit(opuspacket: PackedByteArray) -> void:
	if len(chunkprefix) == 2:
		opuspacket[0] = (opusframecount%256)  # 32768 frames is 10 minutes
		opuspacket[1] = (int(opusframecount/256)&127) + (opusstreamcount%2)*128
	transmit_audio_packet.emit(opuspacket)
	opusframecount += 1


func processopuschunk():
	assert(currentlytalking)
	_stamp_and_emit(_encode_chunk_raw())


## Пока VOX ещё не сработал (currentlytalking == false), не выбрасываем
## закодированный чанк, а копим последние lead_time секунд про запас.
func _buffer_lead_chunk() -> void:
	_lead_buffer.push_back(_encode_chunk_raw())
	while _lead_buffer.size() > _lead_frames_cap:
		_lead_buffer.pop_front()


var audio_chunk = null
var last_chunkmax = 0.0

func _process(delta):
	microphoneaudiosamplescountSeconds += delta
	processtalkstreamends(pttbutton.button_pressed)
	while true:
		audio_chunk = AudioServer.get_input_frames(opusencoder.get_required_input_chunk_size())
		if len(audio_chunk) == 0:
			break
		if opusencoder.process_chunk(audio_chunk) < 0:
			break
		if denoisebutton.button_pressed:
			last_chunkmax = opusencoder.get_speech_probability()
		elif rootmeansquaremaxmeasurement:
			last_chunkmax = opusencoder.get_rms()
		else:
			last_chunkmax = opusencoder.get_peak()
		microphoneaudiosamplescount += len(audio_chunk)
		if microphoneaudiosamplescountSeconds > microphoneaudiosamplescountSecondsSampleWindow:
			print("measured mic audiosamples rate ", microphoneaudiosamplescount/microphoneaudiosamplescountSeconds)
			microphoneaudiosamplescount = 0
			microphoneaudiosamplescountSeconds = 0.0
			microphoneaudiosamplescountSecondsSampleWindow *= 1.5
		processvox(last_chunkmax, audio_chunk)
		if currentlytalking:
			processopuschunk()
		else:
			_buffer_lead_chunk()
	audio_chunk = null
