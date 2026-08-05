extends Node


var base_path = OS.get_executable_path().get_base_dir()
var SAVE_PATH = base_path.path_join("user_bd.tres")
var user := []

const PORT := 6767
const SERVER_CONTROL_PORT := 6768
const LOBBY_PORT_START := 6770
const LOBBY_PORT_END := 6969
var SERVER_CONTROL


var lobbies := {}
var used_ports := {}

var PEER
var online := 0
var online_global := 0

var server_command = {
	"!user_edit" : user_edit_admin,
	"!reg_acc" : reg_acc,
	"!log_acc" : log_acc,
	"!request_avatar" : request_avatar,
	"!request_avatar_lobby" : request_avatar_lobby,
	"!set_avatar" : set_avatar,
	"!user_list_update" : user_list_update,
	"!lobby_list_update": lobby_list_update,
	"!lobby_new_create": lobby_new_create,
	"!connect_user_lobby" : connect_user_lobby,
	"!lobby_players_count": lobby_players_count,
	"!lobby_ready" : lobby_ready,
	"!lobby_close" : lobby_close,
	"!lobby_service" : lobby_service,
	"!lobby_connect_request" : connect_user_lobby,
}

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--server" in args:
		R.status = "SERVER"
		pass
	else:
		queue_free()
		return
	
	print("Запуск в режиме сервера")
	PEER = WebSocketMultiplayerPeer.new()
	if PEER.create_server(PORT) != OK:
		print("ошибка")
		return
	multiplayer.multiplayer_peer = PEER
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	
	load_user_db()
	save_user_bd()
	
	for u in user:
		u.LOG_IN = ""
	save_user_bd()
	
	#SERVER_CONTROL
	await get_tree().create_timer(1.0).timeout
	SERVER_CONTROL = Node.new()
	SERVER_CONTROL.name = "SERVER_CONTROL"
	get_tree().root.add_child(SERVER_CONTROL)
	SERVER_CONTROL.set_script(preload("res://scr/SERVER_CONTROL.gd"))
	
	var SERVER_CONTROL_SM := SceneMultiplayer.new()
	get_tree().set_multiplayer(SERVER_CONTROL_SM, SERVER_CONTROL.get_path())
	var SERVER_CONTROL_SP := WebSocketMultiplayerPeer.new()
	SERVER_CONTROL_SP.create_server(SERVER_CONTROL_PORT)
	SERVER_CONTROL.multiplayer.multiplayer_peer = SERVER_CONTROL_SP



func online_update():
	await get_tree().create_timer(1.0).timeout
	online_global = online
	for lobby_id in lobbies:
		online_global += lobbies[lobby_id]["players_count"]
	print("Общий онлайн: ", online_global)


func player_connected(id):
	print("Подключился ", id)
	online += 1
	online_update()
	#print(online)

func player_disconnected(id):
	print("Отключился ", id)
	online -= 1
	print(online)
	for u in user:
		if u.LOG_IN == str(id):
			u.LOG_IN = ""
	save_user_bd()

func send_server_command(data):
	R.rpc("send_server_command", data)

func send_server_command_to_id(id, data):
	R.rpc_id(id, "send_server_command", data)


func save_user_bd():
	var arr := AccDataArray.new()
	arr.data = user
	if ResourceSaver.save(arr, SAVE_PATH) == OK:
		return

func load_user_db():
	if ResourceLoader.exists(SAVE_PATH):
		var res = ResourceLoader.load(SAVE_PATH)
		if res is AccDataArray:
			user = res.data
			print("Загружено ", user.size(), " пользователей")
		else:
			user = []
	else:
		user = []

func user_edit_admin(data):
	var id = int(data[data.size()-1])
	for u in user:
		if u.USERNAME == "admin":
			if u.LOG_IN == str(id):
				print("Редактирование пользователя админом..")
				var cmd_username = data[1]
				var cmd_parametrs = data[2]
				var cmd_type = data[3]
				var cmd_value = data[4]
				
				if cmd_type == "bool":
					if cmd_value == "true":
						cmd_value = true
					elif cmd_value == "false":
						cmd_value = false
				
				if cmd_type == "int":
					cmd_value = int(cmd_value)
				
				if cmd_type == "str":
					cmd_value = str(cmd_value)
				
				for cmd_u in user:
					if cmd_u.USERNAME == str(cmd_username):
						cmd_u.set(cmd_parametrs, cmd_value)
						print("Выполнена команда: ", cmd_parametrs, " для пользователя ", cmd_username, " значение ", str(cmd_value))
						save_user_bd()

func reg_acc(data):
	var acc_name = data[1]
	var acc_pass = data[2]
	var u := AccData.new()
	u.USERNAME = acc_name
	u.PASSWORD = acc_pass
	user.append(u)
	save_user_bd()
	log_acc(data)

func log_acc(data):
	if data.size() < 3: return
	var acc_name = data[1]
	var acc_pass = data[2]
	var version_client = data[3]
	var id = int(data[data.size()-1])
	if version_client != R.version:
		data = ["!log_in_version_client_invalid"]
		send_server_command_to_id(id, data)
		return
	for u in user:
		if u.USERNAME == acc_name:
			if u.PASSWORD == acc_pass:
				if u.LOG_IN != "":
					print("Пользователь %s уже есть в системе" % acc_name)
					data = ["!log_in_online_invalid"]
					send_server_command_to_id(id, data)
					return
				u.LOG_IN = str(id)
				save_user_bd()
				user_list_update(data)
				request_avatar(data)
				print("Пользователь %s вошёл" % acc_name)
				data = ["!log_in_success"]
				send_server_command_to_id(id, data)
				return
			else:
				print("Пользователь %s не верный пароль" % acc_name)
				data = ["!log_in_password_invalid"]
				send_server_command_to_id(id, data)
				return
	print("Пользователь %s не найден, регистрация..." % acc_name)
	reg_acc(data)

func request_avatar(data):
	var username = data[1]
	var id = int(data[data.size()-1])
	for u in user:
		if u.USERNAME == username:
			var b64 = u.avatar_to_base64()
			data = ["!update_avatar", username, b64]
			send_server_command_to_id(id, data)
			return
	data = ["!update_avatar", username, null]
	

func request_avatar_lobby(data):
	var players_user = data[1]
	var id = int(data[data.size()-1])
	for u2 in players_user:
		var username = players_user[u2]["username"]
		for u in user:
			if u.USERNAME == username:
				var b64 = u.avatar_to_base64()
				data = ["!update_avatar", username, b64]
				SERVER_CONTROL.send_server_command.rpc_id(id, data)
				await get_tree().create_timer(0.02).timeout



func set_avatar(data):
	var id = int(data[data.size()-1])
	var username = data[1]
	var b64 = data[2]
	for u in user:
		if u.USERNAME == username:
			u.avatar = AccData.avatar_from_base64(b64)
			save_user_bd()
			send_server_command_to_id(id, ["!update_avatar", username, b64])
			return

func user_list_update(data):
	var id = int(data[data.size()-1])
	var serialized = []
	for u in user:
		serialized.append(u.to_dict())
	#print("SERVER: Отправляю сериализованный список: ", serialized)
	data = ["!user_list_update", serialized]
	send_server_command_to_id(id, data)



func lobby_list_update(data):
	var id = int(data[data.size() - 1])
	data.clear()
	for lobby_id in lobbies.keys():
		var info = lobbies[lobby_id]
		if info["status"] == "ready" or info["status"] == "in_game":
			data.append({
				"lobby_id": lobby_id,
				"port": info["port"],
				"name": info["name"],
				"leader" : info["lobby_leader"],
				"status": info["status"],
				"players_count": info["players_count"],
			})
	send_server_command_to_id(id, ["!lobby_list_update", data])

func lobby_new_create(data):
	var id = int(data[data.size() - 1])
	var path = OS.get_executable_path()
	var debag_path
	var args = PackedStringArray()
	var port = find_free_port()
	var new_lobby_name = data[1]
	var new_lobby_password = data[2]
	var new_lobby_leader = data[3]
	
	#args.append("--headless")
	
	if port == -1:
		print("Нет свободных портов")
		return
	
	if OS.has_feature("editor"):
		print("Запущено из редактора Godot")
		debag_path = ProjectSettings.globalize_path("res://")
		args.append("--path")
		args.append(debag_path)
	else:
		print("Запущено из релизной версии")
		pass
	
	args.append("--")
	args.append("--server_game")
	args.append("--port=" + str(port))
	args.append("--lobby_name=" + str(new_lobby_name))
	
	
	var pid = OS.create_process(path, args)
	await get_tree().create_timer(0.1).timeout
	if pid > 0:
		print("Новый экземпляр успешно запущен. PID: ", pid)
	else:
		print("Ошибка: не удалось запустить новый экземпляр.")
		return
	
	lobbies[pid] = {
		"name" : str(new_lobby_name),
		"password" : str(new_lobby_password),
		"lobby_leader" : str(new_lobby_leader),
		"port" : port,
		"mod" : "casual",
		"status" : "start",
		"players_count" : 0,
		"players_user" : null,
	}
	
	await get_tree().create_timer(3.0).timeout
	if lobbies.has(pid) and lobbies[pid]["status"] == "ready":
		data = ["!lobby_connect", lobbies[pid]["port"], lobbies[pid]["name"]]
		send_server_command_to_id(id, data)
		print("Подключаю лидера лобби...")
	else:
		data = ["!lobby_connect_error"]
		send_server_command_to_id(id, data)
		print("Ошибка подключения лидера лобби")

func find_free_port():
	for port in range(LOBBY_PORT_START, LOBBY_PORT_END):
		if used_ports.has(port):
			continue
		else:
			if lobbies.has(port):
				continue
			used_ports[port] = true
			used_ports[port+1] = true
			return port
	return -1

func connect_user_lobby(data):
	var id = int(data[data.size() - 1])
	var port = int(data[1])
	var lobby_name = str(data[2])
	var lobby_password = str(data[3])
	for l in lobbies:
		if lobbies[l]["name"] == lobby_name and lobbies[l]["port"] == port and lobbies[l]["password"] == lobby_password and lobbies[l]["status"] == "ready":
			data = ["!lobby_connect", port, lobby_name]
			send_server_command_to_id(id, data)
		else:
			data = ["!lobby_connect_error"]
			send_server_command_to_id(id, data)

func lobby_players_count(data):
	var players_count = data[1]
	var lobby_pid = int(data[2])
	var players_user = data[3]
	data.clear()
	print(lobbies)
	if lobby_pid in lobbies:
		lobbies[lobby_pid]["players_count"] = players_count
		lobbies[lobby_pid]["players_user"] = players_user
		#print("число игроков в лобби: ", lobbies[lobby_pid]["players_count"])
	
	online_update()
	
	#SERVER_CONTROL.send_server_command.rpc(data)

func lobby_ready(data):
	var lobby_name = data[1]
	var lobby_port = data[2]
	for l in lobbies:
		if lobbies[l]["status"] == "start":
			if lobbies[l]["name"] == str(lobby_name) and lobbies[l]["port"] == int(lobby_port):
				lobbies[l]["status"] = "ready"
				data = ["!lobby_send_pid", l, lobbies[l]["lobby_leader"]]
				SERVER_CONTROL.send_server_command.rpc(data)

func lobby_close(data):
	var lobby_name = data[1]
	var lobby_port = data[2]
	var lobby_pid = data[3]
	for l in lobbies:
		if l == lobby_pid:
			await get_tree().create_timer(0.5).timeout
			print("Лобби ", lobby_pid, " ", lobby_name," завершено")
			lobbies.erase(l)
	used_ports.erase(lobby_port)
	used_ports.erase(lobby_port+1)

func lobby_service(data):
	var lobby_name = data[1]
	var lobby_port = data[2]
	var lobby_command = data[3]
	for l in lobbies:
		if lobbies[l]["status"] == "ready" and lobby_command == "game_start":
			if lobbies[l]["name"] == str(lobby_name) and lobbies[l]["port"] == int(lobby_port):
				lobbies[l]["status"] = "in_game"












#
