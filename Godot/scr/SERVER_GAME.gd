extends Node

const CENTRAL_SERVER = "ws://127.0.0.1:6768"
var SERVER_CONTROL

var CENTRAL_STATUS = false
var rng

var PEER
var PORT
var LOBBY_PID
var LOBBY_NAME
var LOBBY_LEADER
var players_count := 0
var VOICE

var in_game := false
var game_scene

var players_user := {}

var lobby_parametrs = {
	"mode" : "0",
	"spawn" : "1",
	"koloda" : "8",
	"bot" : "1",
	"map" : "0",
}

var server_game_command = {
	"!lobby_send_pid" : lobby_set_pid,
	"!check_user_in_lobby_return" : check_user_in_lobby_return,
	"!lobby_parametrs_update" : lobby_parametrs_update,
	"!lobby_parametrs_user_update" : lobby_parametrs_user_update,
	"!START_GAME" : START_GAME,
	"!update_avatar": update_avatar,
}

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	randomize()
	var args := OS.get_cmdline_user_args()
	if args.size() == 0:
		queue_free()
		return
	
	for a in args:
		if a == "--server_game":
			R.status = "SERVER_GAME"
		elif a.begins_with("--port="):
			PORT = a.get_slice("=", 1).to_int()
		elif a.begins_with("--lobby_name="):
			LOBBY_NAME = a.get_slice("=", 1)
		else:
			if !R.status == "SERVER_GAME":
				queue_free()
				return
	
	await get_tree().create_timer(0.5).timeout
	
	PEER = WebSocketMultiplayerPeer.new()
	if PEER.create_server(PORT) != OK:
		print("Ошибка запуска игрового сервера на порту ", PORT)
		queue_free()
		return
	multiplayer.multiplayer_peer = PEER
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	
	#SERVER_CONTROL
	await get_tree().create_timer(0.5).timeout
	SERVER_CONTROL = Node.new()
	SERVER_CONTROL.name = "SERVER_CONTROL"
	get_tree().root.add_child(SERVER_CONTROL)
	SERVER_CONTROL.set_script(preload("res://scr/SERVER_CONTROL.gd"))
	var SERVER_CONTROL_SM := SceneMultiplayer.new()
	get_tree().set_multiplayer(SERVER_CONTROL_SM, SERVER_CONTROL.get_path())
	var SERVER_CONTROL_SP := WebSocketMultiplayerPeer.new()
	if SERVER_CONTROL_SP.create_client(CENTRAL_SERVER)!= OK:
		print("Ошибка подключения к центральному серверу")
		queue_free()
		return
	SERVER_CONTROL.multiplayer.multiplayer_peer = SERVER_CONTROL_SP
	SERVER_CONTROL.multiplayer.connected_to_server.connect(_central_connected)
	SERVER_CONTROL.multiplayer.connection_failed.connect(_central_failed)
	SERVER_CONTROL.multiplayer.server_disconnected.connect(_central_disconnected)
	
	
	await get_tree().process_frame
	#get_tree().call_deferred("change_scene_to_file", "res://lvl/game/lobby.tscn")
	
	var dead_timer = Timer.new()
	dead_timer.wait_time = 20.0
	dead_timer.one_shot = false
	dead_timer.timeout.connect(dead_timer_timeout)
	get_tree().root.add_child(dead_timer)
	dead_timer.start()

func dead_timer_timeout():
	if players_count <= 0:
		var data = ["!lobby_close", LOBBY_NAME, PORT, LOBBY_PID]
		SERVER_CONTROL.send_server_game_command.rpc(data)
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()


func _central_connected():
	var data = ["!lobby_ready", LOBBY_NAME, PORT]
	SERVER_CONTROL.send_server_game_command.rpc(data)
	print("Подключено к центральному серверу")
	CENTRAL_STATUS = true

func _central_failed():
	print("Не удалось подключиться к центральному серверу")

func _central_disconnected():
	print("Центральный сервер отключился")
	await get_tree().create_timer(10.0).timeout
	if !CENTRAL_STATUS:
		get_tree().quit()


func send_server_command(data):
	R.rpc("send_server_command", data)

func send_server_command_to_id(id, data):
	R.rpc_id(id, "send_server_command", data)


func _player_connected(id):
	var user_param = {
		"username" : "",
		"king" : "0",
		"spawn" : "0",
	}
	
	players_user[id] = user_param
	print("Подключился ",id)
	players_count += 1
	var data = ["!lobby_players_count", players_count, LOBBY_PID, players_user]
	SERVER_CONTROL.send_server_game_command.rpc(data)
	data = ["!check_user_in_lobby", LOBBY_LEADER]
	send_server_command_to_id(id, data)
	
	await get_tree().create_timer(0.1).timeout
	data = null
	lobby_parametrs_update(data)

func _player_disconnected(id):
	print("Отключился ", id)
	players_count -= 1
	var data = ["!lobby_players_count", players_count, LOBBY_PID, players_user]
	SERVER_CONTROL.send_server_game_command.rpc(data)
	players_user.erase(id)
	
	await get_tree().create_timer(0.1).timeout
	data = null
	lobby_parametrs_update(data)


func lobby_set_pid(data):
	LOBBY_PID = data[1]
	LOBBY_LEADER = data[2]
	print("Установлен ID и лобби лидер ", LOBBY_PID, " ", LOBBY_LEADER)

func check_user_in_lobby_return(data):
	var id = int(data[data.size() - 1])
	players_user[id]["username"] = str(data[1])

func lobby_parametrs_update(data):
	if data == null:
		data = ["!lobby_parametrs_update", lobby_parametrs, players_user]
		send_server_command(data)
	else:
		var id = int(data[data.size() - 1])
		lobby_parametrs = data[1]
		
		match lobby_parametrs["spawn"]:
			"2" : 
				for u in players_user:
					players_user[u]["king"] = "1"
					players_user[u]["spawn"] = "1"
			"3" :
				for u in players_user:
					players_user[u]["king"] = "1"
			"4" :
				for u in players_user:
					players_user[u]["spawn"] = "1"
		
		data = ["!lobby_parametrs_update", lobby_parametrs, players_user]
		send_server_command(data)

func lobby_parametrs_user_update(data):
	if data == null:
		return
	players_user = data[1]
	data = null
	lobby_parametrs_update(data)

func START_GAME(data):
	var start_data = data
	rand_king()
	rand_spawn()
	data = ["!lobby_parametrs_update", lobby_parametrs, players_user]
	send_server_command(data)
	await get_tree().create_timer(1.0).timeout
	data = start_data
	send_server_command(data)
	await get_tree().create_timer(0.1).timeout
	data = ["!lobby_service", LOBBY_NAME, PORT, "game_start"]
	SERVER_CONTROL.send_server_game_command.rpc(data)
	in_game = true
	var game_node = preload("res://lvl/game/game.tscn").instantiate()
	get_tree().root.add_child(game_node)
	game_scene = get_tree().root.get_node("GAME")
	game_scene.rpc("spawn_start")
	await get_tree().create_timer(1.0).timeout
	data = ["!lobby_parametrs_update", lobby_parametrs, players_user]
	send_server_command(data)
	
	await get_tree().create_timer(0.1).timeout
	data.clear()
	data = ["!request_avatar_lobby", players_user]
	SERVER_CONTROL.send_server_game_command.rpc(data)
	data.clear()


func rand_king():
	var king_use = []
	var king_no_use = []
	var user_rand = []
	for u in players_user:
		if players_user[u]["king"] == "1":
			user_rand.append(u)
		elif players_user[u]["king"] == "0":
				pass
		else:
			if king_use.has(players_user[u]["king"]):
				players_user[u]["king"] = "0"
			king_use.append(players_user[u]["king"])
	
	for i in range(2, 8):
		if not i in king_use:
			king_no_use.append(str(i))
	king_no_use.shuffle()
	
	for u in user_rand:
		if king_no_use.is_empty():
			players_user[u]["king"] = "0"
			continue
		players_user[u]["king"] = king_no_use.pop_back()

func rand_spawn():
	var spawn_use = []
	var spawn_no_use = []
	var user_rand = []
	for u in players_user:
		if players_user[u]["spawn"] == "1":
			user_rand.append(u)
		elif players_user[u]["spawn"] == "0":
				pass
		else:
			if spawn_use.has(players_user[u]["spawn"]):
				players_user[u]["spawn"] = "0"
			spawn_use.append(players_user[u]["spawn"])
	
	for i in range(2, 8):
		if not i in spawn_use:
			spawn_no_use.append(str(i))
	spawn_no_use.shuffle()
	
	for u in user_rand:
		if spawn_no_use.is_empty():
			players_user[u]["spawn"] = "0"
			continue
		players_user[u]["spawn"] = spawn_no_use.pop_back()


func update_avatar(data):
	data = ["!update_avatar_in_game", data]
	send_server_command(data)
























#
