extends Node
var version = ProjectSettings.get_setting("application/config/version", "1.0.0")
var status := "" #CLIENT, SERVER, SERVER_GAME


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	print(args)


@rpc("any_peer")
func send_player_command(data):
	if status == "CLIENT":
		return
	var user_id = multiplayer.get_remote_sender_id()
	if data.size()>0:
		data.append(str(user_id))
		var cmd = data[0]
		if status == "SERVER":
			if cmd in S.server_command:
				S.server_command[cmd].call(data)
		if status == "SERVER_GAME":
			if cmd in SG.server_game_command:
				SG.server_game_command[cmd].call(data)

@rpc()
func send_server_command(data):
	if status == "SERVER":
		return
	if data.size()>0:
		if multiplayer.get_remote_sender_id() == 1:
			var cmd = data[0]
			if cmd in C.user_command:
				C.user_command[cmd].call(data)


@rpc("any_peer", "call_local", "unreliable", 1)
func relay_audio(packet: PackedByteArray):
	# Пересылаем всем клиентам, кроме отправителя
	var sender = multiplayer.get_remote_sender_id()
	for peer in multiplayer.get_peers():
		if peer != sender:
			#print("relay_audio from ", sender, " to peers")
			rpc_id(peer, "receive_audio", packet, sender)


@rpc("any_peer", "call_local", "unreliable", 1)
func relay_audio_json(json_str: PackedByteArray):
	var sender = multiplayer.get_remote_sender_id()
	for peer in multiplayer.get_peers():
		if peer != sender:
			rpc_id(peer, "receive_audio_json", json_str, sender)




@rpc("call_local")
func receive_audio(packet: PackedByteArray, sender_id: int):
	Audio.receive_audio(packet, sender_id)

@rpc("call_local")
func receive_audio_json(json_str: PackedByteArray, sender_id: int):
	Audio.receive_audio_json(json_str, sender_id)












#
