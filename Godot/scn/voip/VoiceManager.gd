extends Node
class_name VoiceManager

@export var voice: VoiceNet
@export var game: GameNet
@export var mic: Node                 # инстанс two_voip_mic.gd (микрофон локального игрока)
@export var players_container: Control   # VBoxContainer (или любой Container), куда добавляются плашки
@export var player_row_scene: PackedScene # PlayerRow.tscn (см. player_row.gd)

const SpeakerScript := preload("res://addons/twovoip/voiphelper/two_voip_speaker.gd")

var _speakers: Dictionary = {}       # peer_id(int) -> Node (two_voip_speaker)
var _audio_players: Dictionary = {}  # peer_id(int) -> AudioStreamPlayer
var _rows: Dictionary = {}           # peer_id(int) -> Control (плашка игрока)


func _ready() -> void:
	mic = $Mic
	
	mic.init_voip_mic(
		true, 
		$"../mic/MicOn", 
		$"../mic/InputOption", 
		$"../mic/PTT", 
		$"../mic/Vox", 
		$"../mic/Denoise", 
		null)
	mic.set_opus_values(
		48000, 
		20, 
		1, 
		20000, 
		5, 
		true)
	
	
	if get_tree().root.has_node("NET/net_voice"):
		voice = get_tree().root.get_node("NET/net_voice")
	if get_tree().root.has_node("NET/net_game"):
		game = get_tree().root.get_node("NET/net_game")
	if get_tree().root.has_node("RUN/LOBBY/list_user"):
		players_container = get_tree().root.get_node("RUN/LOBBY/list_user")
	player_row_scene = preload("res://scn/voip/PlayerRow.tscn")
	
	assert(game != null, "VoiceManager: не назначен GameNet (game)")
	assert(voice != null, "VoiceManager: не назначен VoiceNet (voice)")
	assert(players_container != null, "VoiceManager: не назначен players_container")

	game.peer_connected.connect(_on_game_peer_connected)
	game.peer_disconnected.connect(_on_game_peer_disconnected)
	if not game.game_connected.is_connected(_on_game_connected):
		game.game_connected.connect(_on_game_connected)
	if game.get_my_id() > 0:
		_on_game_connected()

	voice.voice_packet_received.connect(_on_voice_packet_received)

	if mic:
		# Микрофон должен эмитить БИНАРНЫЕ пакеты (json_packets_as_binary = true
		# при вызове init_voip_mic), т.к. VOICE.send_voice() шлёт только PackedByteArray
		# через WRITE_MODE_BINARY.
		mic.transmit_audio_packet.connect(_on_mic_packet)


# --- как только локальный игрок получил свой multiplayer id от GAME,
#     сообщаем этот же id голосовому транспорту, чтобы peer_id совпадали
#     между GAME и VOICE для одного и того же человека ---
func _on_game_connected() -> void:
	voice.set_my_peer_id(game.get_my_id())


# --- микрофон -> голосовой сокет ---
func _on_mic_packet(data: PackedByteArray) -> void:
	voice.send_voice(data)


# --- голосовой сокет -> декодер конкретного собеседника ---
func _on_voice_packet_received(sender_id: int, data: PackedByteArray) -> void:
	var speaker: Node = _speakers.get(sender_id)
	if speaker == null:
		# Пакет от игрока, для которого ещё не создан speaker (например VOICE
		# подключился быстрее, чем успела прийти GAME.peer_connected). Просто игнорируем —
		# как только плашка/speaker для него создастся, поток продолжится с ближайшего заголовка.
		return
	speaker.receive_audio_packet(data)


# --- GAME сообщил, что подключился новый игрок: плашка + speaker создаются ВМЕСТЕ,
#     но именно факт создания определяется GAME, а не VOICE ---
func _on_game_peer_connected(id: int) -> void:
	if id == 1:
		return
	_create_player_row(id)
	_create_speaker(id)


func _on_game_peer_disconnected(id: int) -> void:
	if id == 1:
		return
	_remove_player_row(id)
	_remove_speaker(id)


func _create_player_row(id: int) -> void:
	if _rows.has(id):
		return
	var row: Control = player_row_scene.instantiate()
	players_container.add_child(row)
	row.setup(id)
	row.volume_changed.connect(_on_row_volume_changed.bind(id))
	_rows[id] = row


func _remove_player_row(id: int) -> void:
	var row: Control = _rows.get(id)
	if row:
		row.queue_free()
	_rows.erase(id)


func _create_speaker(id: int) -> void:
	if _speakers.has(id):
		return

	var audio_player := AudioStreamPlayer.new()
	audio_player.name = "AudioPlayer_%d" % id
	audio_player.bus = "Voice"
	# audio_player.bus = "Voice"  # раскомментируйте, если создадите отдельную шину "Voice"
	add_child(audio_player)

	# two_voip_speaker._ready() делает:
	#   audioplayeropus = get_parent().findaudioplayer() if has_method(...) else get_parent()
	# У AudioStreamPlayer такого метода нет, поэтому get_parent() (сам AudioStreamPlayer)
	# и станет audioplayeropus — этого достаточно (есть set_stream/play/playing).
	var speaker := Node.new()
	speaker.name = "Speaker_%d" % id
	speaker.set_script(SpeakerScript)
	audio_player.add_child(speaker)

	_speakers[id] = speaker
	_audio_players[id] = audio_player


func _remove_speaker(id: int) -> void:
	var audio_player: AudioStreamPlayer = _audio_players.get(id)
	if audio_player:
		audio_player.queue_free()  # заодно освобождает и дочерний speaker
	_speakers.erase(id)
	_audio_players.erase(id)


func _on_row_volume_changed(value: float, id: int) -> void:
	var audio_player: AudioStreamPlayer = _audio_players.get(id)
	if audio_player:
		audio_player.volume_linear = value
