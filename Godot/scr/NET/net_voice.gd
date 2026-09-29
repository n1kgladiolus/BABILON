extends Node
class_name VoiceNet

signal voice_connected
signal voice_disconnected
signal voice_error(message: String)
signal voice_packet_received(sender_id: int, data: PackedByteArray)

const HEADER_SIZE        := 4
const MAGIC_HANDSHAKE    := "VOICE1"
const HANDSHAKE_TIMEOUT  := 10.0
const MAX_PEER_ID        := 0x7FFFFFFF

var _mode: String = ""

# --- client ---
var _client_socket: WebSocketPeer
var _client_connected := false
var _my_peer_id: int = 0
var _handshake_sent := false

# --- server ---
var _tcp_server: TCPServer
# conn_id -> { ws: WebSocketPeer, peer_id: int, handshake_done: bool, handshake_ts: float }
var _clients: Dictionary = {}
var _next_conn_id := 1

func setup(mode: String, config: Dictionary) -> void:
	_mode = mode
	set_process(true)
	match mode:
		"client": _setup_client(config)
		"server": _setup_server(config)
		_: push_error("[VOICE] Unknown mode: %s" % mode)


func set_my_peer_id(id: int) -> void:
	_my_peer_id = id
	_handshake_sent = false


func send_voice(data: PackedByteArray) -> void:
	if _mode != "client":
		return
	if _client_socket == null:
		return
	if _client_socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	if data.is_empty():
		return
	_client_socket.send(data, WebSocketPeer.WRITE_MODE_BINARY)


func disconnect_voice() -> void:
	if _mode == "client":
		if _client_socket:
			_client_socket.close(1000, "Client disconnect")
			_client_socket = null
		_client_connected = false
		_handshake_sent = false
	elif _mode == "server":
		for conn_id in _clients.keys():
			var ws: WebSocketPeer = _clients[conn_id]["ws"]
			if ws:
				ws.close(1001, "Server shutting down")
		_clients.clear()
		if _tcp_server:
			_tcp_server.stop()
			_tcp_server = null
	set_process(false)


func get_connected_peer_ids() -> Array:
	var out := []
	if _mode != "server":
		return out
	for conn_id in _clients.keys():
		var e: Dictionary = _clients[conn_id]
		if e["handshake_done"]:
			out.append(e["peer_id"])
	return out

func _process(delta: float) -> void:
	match _mode:
		"client": _process_client()
		"server": _process_server(delta)


func _setup_client(config: Dictionary) -> void:
	var url: String = config.get("url", "")
	if url.is_empty():
		voice_error.emit("VOICE client url is empty")
		return
	_client_socket = WebSocketPeer.new()
	_client_socket.outbound_buffer_size = 1024 * 1024
	_client_socket.inbound_buffer_size  = 1024 * 1024
	var err := _client_socket.connect_to_url(url)
	print("[VOICE] connect_to_url result: ", err, " url: ", url)
	if err != OK:
		voice_error.emit("VOICE client connect failed: %s" % err)


func _process_client() -> void:
	if _client_socket == null:
		return
	_client_socket.poll()
	var state := _client_socket.get_ready_state()
	match state:
		WebSocketPeer.STATE_OPEN:
			if not _client_connected:
				print("[VOICE] Client WebSocket OPENED")
				_client_connected = true
				voice_connected.emit()
			if not _handshake_sent and _my_peer_id > 0:
				var hs := "%s%d" % [MAGIC_HANDSHAKE, _my_peer_id]
				var err := _client_socket.send_text(hs)
				if err == OK:
					_handshake_sent = true
				else:
					push_warning("[VOICE] handshake send failed: %s" % err)
			while _client_socket.get_available_packet_count() > 0:
				var packet := _client_socket.get_packet()
				if packet.size() < HEADER_SIZE:
					continue
				var sender_id := packet.decode_u32(0)
				var payload := packet.slice(HEADER_SIZE)
				voice_packet_received.emit(sender_id, payload)
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CLOSED:
			if _client_connected:
				var code := _client_socket.get_close_code()
				var reason := _client_socket.get_close_reason()
				print("[VOICE] Client disconnected: code=%d reason=%s" % [code, reason])
				_client_connected = false
				_handshake_sent = false
				voice_disconnected.emit()
			set_process(false)


func _setup_server(config: Dictionary) -> void:
	var port: int = config.get("port", 9082)
	_tcp_server = TCPServer.new()
	var err := _tcp_server.listen(port, "*")
	if err != OK:
		voice_error.emit("VOICE server listen failed on port %d: %s" % [port, err])
		return
	print("[VOICE] Server listening on port ", port)


func _process_server(_delta: float) -> void:
	if _tcp_server == null:
		return
	while _tcp_server.is_connection_available():
		var conn := _tcp_server.take_connection()
		if conn == null:
			continue
		var ws := WebSocketPeer.new()
		ws.outbound_buffer_size = 1024 * 1024
		ws.inbound_buffer_size  = 1024 * 1024
		var err := ws.accept_stream(conn)
		if err != OK:
			push_warning("[VOICE] accept_stream failed: %s" % err)
			continue
		var conn_id := _next_conn_id
		_next_conn_id += 1
		_clients[conn_id] = {
			"ws":             ws,
			"peer_id":        0,
			"handshake_done": false,
			"handshake_ts":   Time.get_ticks_msec() / 1000.0,
		}
	var to_remove: Array = []
	var now := Time.get_ticks_msec() / 1000.0
	for conn_id in _clients.keys():
		var entry: Dictionary = _clients[conn_id]
		var ws: WebSocketPeer = entry["ws"]
		ws.poll()
		var state := ws.get_ready_state()
		match state:
			WebSocketPeer.STATE_OPEN:
				_read_packets_from_client(conn_id, ws, entry)
				if not entry["handshake_done"]:
					if now - entry["handshake_ts"] > HANDSHAKE_TIMEOUT:
						push_warning("[VOICE] Handshake timeout (conn %d)" % conn_id)
						ws.close(1002, "Handshake timeout")
						to_remove.append(conn_id)
			WebSocketPeer.STATE_CLOSING:
				pass
			WebSocketPeer.STATE_CLOSED:
				var code := ws.get_close_code()
				var reason := ws.get_close_reason()
				if entry["handshake_done"]:
					print("[VOICE] Client peer_id=%d (conn %d) closed: code=%d reason=%s"
						% [entry["peer_id"], conn_id, code, reason])
				else:
					print("[VOICE] Client conn %d closed before handshake: code=%d" % [conn_id, code])
				to_remove.append(conn_id)
	for conn_id in to_remove:
		_clients.erase(conn_id)


func _read_packets_from_client(conn_id: int, ws: WebSocketPeer, entry: Dictionary) -> void:
	while ws.get_available_packet_count() > 0:
		var packet := ws.get_packet()
		var was_text := ws.was_string_packet()
		if not entry["handshake_done"]:
			_handle_handshake(conn_id, ws, entry, packet, was_text)
			continue
		if packet.is_empty():
			continue
		var sender_id: int = entry["peer_id"]
		var relayed := _wrap_with_sender(sender_id, packet)
		_relay_to_others(conn_id, relayed)


func _handle_handshake(conn_id: int, ws: WebSocketPeer, entry: Dictionary,
		packet: PackedByteArray, was_text: bool) -> void:
	if not was_text:
		push_warning("[VOICE] Handshake must be text (conn %d)" % conn_id)
		ws.close(1002, "Bad handshake")
		return
	var text := packet.get_string_from_utf8()
	if not text.begins_with(MAGIC_HANDSHAKE):
		push_warning("[VOICE] Bad magic (conn %d): %s" % [conn_id, text])
		ws.close(1002, "Bad magic")
		return
	var peer_id_str := text.substr(MAGIC_HANDSHAKE.length())
	if not peer_id_str.is_valid_int():
		push_warning("[VOICE] Invalid peer_id (conn %d): %s" % [conn_id, peer_id_str])
		ws.close(1002, "Bad peer_id")
		return
	var peer_id := int(peer_id_str)
	if peer_id <= 0 or peer_id > MAX_PEER_ID:
		ws.close(1002, "Bad peer_id range")
		return
	for other_id in _clients.keys():
		if other_id == conn_id:
			continue
		var other: Dictionary = _clients[other_id]
		if other["handshake_done"] and other["peer_id"] == peer_id:
			push_warning("[VOICE] Duplicate peer_id %d — kicking conn %d" % [peer_id, conn_id])
			ws.close(1008, "Duplicate peer_id")
			return
	entry["peer_id"] = peer_id
	entry["handshake_done"] = true
	print("[VOICE] Handshake OK: conn=%d peer_id=%d" % [conn_id, peer_id])


func _relay_to_others(sender_conn_id: int, packet: PackedByteArray) -> void:
	for conn_id in _clients.keys():
		if conn_id == sender_conn_id:
			continue
		var entry: Dictionary = _clients[conn_id]
		if not entry["handshake_done"]:
			continue
		var ws: WebSocketPeer = entry["ws"]
		if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
			ws.send(packet, WebSocketPeer.WRITE_MODE_BINARY)


func _wrap_with_sender(sender_id: int, payload: PackedByteArray) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(HEADER_SIZE)
	out.encode_u32(0, sender_id)
	out.append_array(payload)
	return out
