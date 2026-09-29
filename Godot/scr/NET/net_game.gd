extends Node
class_name GameNet

signal game_connected
signal game_disconnected
signal peer_connected(id: int)
signal peer_disconnected(id: int)

var _api: SceneMultiplayer
var _peer: WebSocketMultiplayerPeer
var _mode: String = ""


func _enter_tree() -> void:
	_api = SceneMultiplayer.new()
	get_tree().set_multiplayer(_api, get_path())


func setup(mode: String, config: Dictionary) -> void:
	disconnect_game()
	_mode = mode
	_peer = WebSocketMultiplayerPeer.new()
	
	if mode == "server":
		var port: int = config.get("port", 9081)
		var err := _peer.create_server(port)
		if err != OK:
			push_error("[GAME] server failed: %s" % error_string(err))
			return
		_api.multiplayer_peer = _peer
		if not _api.peer_connected.is_connected(_on_peer_connected):
			_api.peer_connected.connect(_on_peer_connected)
		if not _api.peer_disconnected.is_connected(_on_peer_disconnected):
			_api.peer_disconnected.connect(_on_peer_disconnected)
		print("[GAME] Server on ", port)
	
	elif mode == "client":
		var url: String = config.get("url", "")
		var err := _peer.create_client(url)
		if err != OK:
			push_error("[net_game] client failed: %s" % error_string(err))
			return
		_api.multiplayer_peer = _peer
		if not _api.connected_to_server.is_connected(_on_connected):
			_api.connected_to_server.connect(_on_connected)
		if not _api.connection_failed.is_connected(_on_connection_failed):
			_api.connection_failed.connect(_on_connection_failed)
		if not _api.server_disconnected.is_connected(_on_server_disconnected):
			_api.server_disconnected.connect(_on_server_disconnected)
		if not _api.peer_connected.is_connected(_on_peer_connected):
			_api.peer_connected.connect(_on_peer_connected)
		if not _api.peer_disconnected.is_connected(_on_peer_disconnected):
			_api.peer_disconnected.connect(_on_peer_disconnected)
		print("[net_game] Connecting ", url)

func _on_peer_connected(id: int) -> void:
	print("[net_game] Peer in ", id)
	peer_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	print("[net_game] Peer out ", id)
	peer_disconnected.emit(id)

func _on_connected() -> void:
	print("[net_game] Connected. id=", multiplayer.get_unique_id())
	game_connected.emit()


func _on_connection_failed() -> void:
	push_error("[net_game] Connection failed")
	game_disconnected.emit()


func _on_server_disconnected() -> void:
	print("[net_game] Server disconnected")
	game_disconnected.emit()


func disconnect_game() -> void:
	if _peer:
		_peer.close()
	_api.multiplayer_peer = null
	_peer = null
	game_disconnected.emit()
	return

func get_my_id() -> int:
	if _api.multiplayer_peer == null:
		return 0
	return _api.get_unique_id()

@rpc("any_peer", "call_remote", "reliable")
func to_server(data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if get_tree().root.has_node("SERVER_GAME"):
		get_tree().root.get_node("SERVER_GAME").command(sender_id, data)

@rpc("authority", "call_remote", "reliable")
func from_server(data: Dictionary) -> void:
	if multiplayer.is_server():
		return
	if get_tree().root.has_node("CLIENT"):
		get_tree().root.get_node("CLIENT").command(data)



#
