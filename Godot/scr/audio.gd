extends Node

@onready var TwoVoipSpeaker = preload("res://addons/twovoip/voiphelper/two_voip_speaker.gd")
@onready var mic = $TwoVoipMic
const Action_sound = {
	"kazna" : preload("res://ost/effect/kazna_new.mp3"),
	"king_dead" : preload("res://ost/effect/losecombat.mp3"),
	"luck" : preload("res://ost/effect/goodluck.mp3"),
	"noluck" : preload("res://ost/effect/badmrle.mp3"),
	
}
#@onready var speaker = $TwoVoipSpeaker
#@onready var audio_player = $VoicePlayer

var players_user_audio := {}

func _ready() -> void:
	pass
	var args := OS.get_cmdline_user_args()
	if "--server" in args or "--server_game" in args:
		queue_free()
		return
	else:
		pass
	
	$Background.finished.connect(background_repeat)
	
	await get_tree().create_timer(0.5).timeout
	mic.initvoipmic(
		C.mic_settings[0], #$MicOnButton,        # кнопка включения микрофона (ToggleButton)
		C.mic_settings[1], #$InputOptionButton,  # выбор устройства ввода (OptionButton)
		C.mic_settings[2], #$PTTButton,          # кнопка PTT (ToggleButton)
		C.mic_settings[3], #$VoxButton,          # кнопка Vox (ToggleButton)
		C.mic_settings[4], #$DenoiseButton,      # кнопка шумоподавления (ToggleButton)
		C.mic_settings[5].material,  # материал для отображения уровня (необязательно)
	)
	
	mic.setopusvalues(48000, 20, 2, 36000, 5, true)
	mic.set_voxthreshhold(0.02)
	#speaker.audioplayeropus = audio_player
	mic.transmitaudiopacket.connect(_on_audio_packet)
	mic.transmitaudiojsonpacket.connect(_on_audio_json_packet)
	
	#var stream = AudioStreamOpus.new()
	#audio_player.stream = stream
	#speaker.audiostreamopus = stream
	_connect_all_ui_elements(get_tree().root)

func findaudioplayer():
	return $VoicePlayer

func _on_audio_packet(opuspacket: PackedByteArray, opusframecount: int):
	if C.in_lobby:
		R.rpc_id(1, "relay_audio", opuspacket)

func _on_audio_json_packet(jsonpacket: Dictionary):
	if C.in_lobby:
		var json_str = JSON.stringify(jsonpacket).to_ascii_buffer()
		R.rpc_id(1, "relay_audio_json", json_str)

func receive_audio(packet: PackedByteArray, sender_id: int):
	if players_user_audio.has(sender_id):
		players_user_audio[sender_id].speaker.tv_incomingaudiopacket(packet)
	else:
		print("Unknown sender: ", sender_id)
	#print(players_user_audio.keys())

func receive_audio_json(json_str: PackedByteArray, sender_id: int):
	if players_user_audio.has(sender_id):
		players_user_audio[sender_id].speaker.tv_incomingaudiopacket(json_str)
	else:
		print("Unknown sender: ", sender_id)


func add_player(player_id: int):
	if players_user_audio.has(player_id):
		return
	var container = Node.new()
	container.name = "Player_" + str(player_id)
	add_child(container)
	var player = AudioStreamPlayer.new()
	player.name = "AudioStreamPlayer"
	player.bus = "VOICE"
	container.add_child(player)
	var speaker = TwoVoipSpeaker.new()
	speaker.name = "TwoVoipSpeaker"
	speaker.audioplayeropus = player
	container.add_child(speaker)
	players_user_audio[player_id] = {
		"container": container,
		"player": player,
		"speaker": speaker
	}
	players_user_audio[player_id].player.volume_db = 15

func remove_player(player_id: int):
	if players_user_audio.has(player_id):
		var data = players_user_audio[player_id]
		data.container.queue_free()
		players_user_audio.erase(player_id)


func set_volume(player_id: int, volume_db: float):
	#print(players_user_audio[player_id].player.volume_db)
	if players_user_audio.has(player_id):
		players_user_audio[player_id].player.volume_db = volume_db

func set_volume_slider(player_id):
	#print(players_user_audio[player_id].player.volume_db)
	if players_user_audio.has(player_id):
		return players_user_audio[player_id].player.volume_db
	return 0.0

func _connect_all_ui_elements(node: Node):
	if node is BaseButton:
		if !node.pressed.is_connected(_on_ui_click):
			node.pressed.connect(_on_ui_click)
	elif node is Tree:
		if !node.item_selected.is_connected(_on_ui_click):
			node.item_selected.connect(_on_ui_click)
	elif node is LineEdit:
		if !node.focus_entered.is_connected(_on_ui_click):
			node.focus_entered.connect(_on_ui_click)
	elif node is Window:
		if !node.visibility_changed.is_connected(_on_ui_click):
			node.visibility_changed.connect(_on_ui_click)
	
	for child in node.get_children():
		_connect_all_ui_elements(child)

func _on_ui_click():
	Audio.get_node("Click").play()


func background_repeat():
	$Background.play()

func Action_sound_play(action):
	$Action.stream = Action_sound[action]
	$Action.play()

func Action2_sound_play(action):
	$Action2.stream = Action_sound[action]
	$Action2.play()





















#
