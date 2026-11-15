extends Node
class_name VoiceManager

@export var voice: VoiceNet
@export var game: GameNet
@export var mic: Node                 # инстанс two_voip_mic.gd (микрофон локального игрока)
@export var players_container: Control   # VBoxContainer (или любой Container), куда добавляются плашки
@export var player_row_scene: PackedScene # PlayerRow.tscn (см. player_row.gd)

const SpeakerScript := preload("res://addons/twovoip/voiphelper/two_voip_speaker.gd")

var _speakers: Dictionary = {}
var _audio_players: Dictionary = {}
var _rows: Dictionary = {}


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
		mic.transmit_audio_packet.connect(_on_mic_packet)


func _on_game_connected() -> void:
	voice.set_my_peer_id(game.get_my_id())


func _on_mic_packet(data: PackedByteArray) -> void:
	voice.send_voice(data)


func _on_voice_packet_received(sender_id: int, data: PackedByteArray) -> void:
	var speaker: Node = _speakers.get(sender_id)
	if speaker == null:
		return
	speaker.receive_audio_packet(data)

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
	audio_player.bus = "players"
	add_child(audio_player)
	var speaker := Node.new()
	speaker.name = "Speaker_%d" % id
	speaker.set_script(SpeakerScript)
	audio_player.add_child(speaker)
	_speakers[id] = speaker
	_audio_players[id] = audio_player


func _remove_speaker(id: int) -> void:
	var audio_player: AudioStreamPlayer = _audio_players.get(id)
	if audio_player:
		audio_player.queue_free()
	_speakers.erase(id)
	_audio_players.erase(id)


func _on_row_volume_changed(value: float, id: int) -> void:
	var audio_player: AudioStreamPlayer = _audio_players.get(id)
	if audio_player:
		audio_player.volume_linear = value
