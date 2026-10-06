extends Node

const LOBBY_PORT_START := 6770
const LOBBY_PORT_END := 6969

var lobbies := {}
var used_ports := {}

var online := 0

var command_list: Dictionary = {
	"client_log_in" : client_log_in,
	"lobby_new_create" : lobby_new_create,
	"lobby_list_update" : lobby_list_update,
	"lobby_start_ok" : lobby_start_ok
	}

var base_path = OS.get_executable_path().get_base_dir()
var SAVE_PATH = base_path.path_join("user_bd.tres")
var user := []



func _ready() -> void:
	UserDataBase()

func _process(delta: float) -> void:
	pass

func send_all(data: Array):
	if R.NET.has_node("net_main"):
		R.NET.get_node("net_main").from_server.rpc(data)

func send_id(id, data: Array):
	if R.NET.has_node("net_main"):
		R.NET.get_node("net_main").from_server.rpc_id(id, data)

func UserDataBase():
	load_user_db()
	save_user_bd()
	for u in user:
		u.LOG_IN = ""
	save_user_bd()

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

func save_user_bd():
	var arr := AccDataArray.new()
	arr.data = user
	if ResourceSaver.save(arr, SAVE_PATH) == OK:
		return

func command(sender_id: int, data: Array):
	if data.size() < 1:
		print("пакет мал")
		return
	if data[0] in command_list:
		command_list[data[0]].call(sender_id, data)
	else:
		print("Нет такой команды")

func client_log_in(sender_id, data):
	if !(data[1].has("USERNAME") and data[1].has("PASSWORD") and data[1].has("VERSION")):
		return
	if ProjectSettings.get_setting("application/config/version", "1.0.0") != data[1]["VERSION"]:
		return
	var acc_name = data[1]["USERNAME"]
	var acc_pass = data[1]["PASSWORD"]
	
	for u in user:
		if u.USERNAME != acc_name:
			continue
		if u.PASSWORD != acc_pass:
			print("Пользователь %s не верный пароль" % acc_name)
			data = ["client_log_in", "Не верный пароль"]
			send_id(sender_id, data)
			return
		if u.LOG_IN != "":
			print("Пользователь %s уже есть в системе" % acc_name)
			data = ["client_log_in", "Пользователь уже в сети"]
			send_id(sender_id, data)
			return
		u.LOG_IN = str(sender_id)
		save_user_bd()
		print("Пользователь %s вошёл" % acc_name)
		data = ["client_log_in", "OK"]
		send_id(sender_id, data)
		return
	
	print("Пользователь %s не найден, регистрация..." % acc_name)
	reg_acc(sender_id, data)

func reg_acc(sender_id, data):
	var u := AccData.new()
	u.USERNAME = data[1]["USERNAME"]
	u.PASSWORD = data[1]["PASSWORD"]
	user.append(u)
	save_user_bd()
	client_log_in(sender_id, data)

func lobby_list_update(sender_id, data):
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
	send_id(sender_id, ["lobby_list_update", data])

func lobby_new_create(sender_id, data):
	var path = OS.get_executable_path()
	var debag_path
	var args = PackedStringArray()
	var port = find_free_port()
	var new_lobby_name = data[1]
	var new_lobby_password = data[2]
	var new_lobby_leader = data[3]
	
	args.append("--headless")
	
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
		data = ["lobby_connect", lobbies[pid]["port"], lobbies[pid]["name"]]
		send_id(sender_id, data)
		print("Подключаю лидера лобби...")
	else:
		data = ["lobby_connect_error"]
		send_id(sender_id, data)
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

func lobby_start_ok(sender_id, data):
	print("Лобби запущено, порт: ", data[1])
	for l in lobbies.keys():
		if lobbies[l]["port"] == data[1]:
			lobbies[l]["status"] = "ready"
		



































































#
