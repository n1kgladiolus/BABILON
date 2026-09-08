extends Node

@rpc("any_peer")
func send_server_game_command(data):
	var user_id = multiplayer.get_remote_sender_id()
	if R.status == "SERVER_GAME":
		return
	var server_id = multiplayer.get_remote_sender_id()
	if data.size()>0:
		data.append(str(user_id))
		data.append(server_id)
		var cmd = data[0]
		if cmd in S.server_command:
			#print("SERVER: статус от game-сервера: ", data)
			S.server_command[cmd].call(data)


@rpc("any_peer")
func send_server_command(data):
	if R.status == "SERVER":
		return
	if data.size()>0:
		if multiplayer.get_remote_sender_id() == 1:
			var cmd = data[0]
			if cmd in SG.server_game_command:
				SG.server_game_command[cmd].call(data)
			#print("SERVER_GAME: команда от SERVER: ", data)
