extends Node

const LOBBY_PORT_START := 6770
const LOBBY_PORT_END := 6969

var lobbies := {}
var used_ports := {}

var online := 0

var command_list: Dictionary = {
	"client_log_in" : client_log_in,
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
	if data.size() < 2:
		return
	if data[0] in command_list:
		command_list[data[0]].call(sender_id, data)

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








































































#
