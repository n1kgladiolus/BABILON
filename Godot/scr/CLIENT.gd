extends Node

var NET
var RUN
var GAME
var MENU

var Curent_Cam: Camera3D

var base_path = OS.get_executable_path().get_base_dir()
var SAVE_PATH = base_path.path_join("client_local_logpass.tres")
var logpass: client_local_logpass
var SETTINGS
var controls_data

var user: Array[AccData] = []
var avatar_user := {}


var log_in_data: Dictionary[String, String] = {
	"USERNAME" : "",
	"PASSWORD" : "",
	"VERSION" : ""
	}

@export var flag: Dictionary[String, bool] = {
	"debug_cam" : false,
	"in_menu" : false,
	"in_game" : false,
	"in_lobby" : false,
	"server_connect" : false,
	}

var command_list: Dictionary = {
	
	}


func _ready() -> void:
	NET = R.NET
	if has_node("/root/RUN"):
		RUN = get_node("/root/RUN")
	if RUN:
		conn_signal()
	
	if ResourceLoader.exists(SAVE_PATH):
		logpass = ResourceLoader.load(SAVE_PATH) as client_local_logpass
		log_in_data["USERNAME"] = logpass.USERNAME
		log_in_data["PASSWORD"] = logpass.PASSWORD
		SETTINGS = logpass.SETTINGS
		controls_data = logpass.controls_data
		logpass.apply_to_input_map()
	else:
		logpass = client_local_logpass.new()
		save_client_local_logpass()
	
	
	if RUN and !RUN.has_node("MENU"):
		RUN.add_child(preload("res://scn/MENU.tscn").instantiate())
		await get_tree().process_frame
		if !RUN.has_node("MENU"):
			printerr("MENU НЕ НАЙДЕНО")
		MENU = RUN.get_node("MENU")
		await get_tree().process_frame
		Curent_Cam = MENU.get_node("Menu_cam")




func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("debug_cam"):
		debug_cam()


func command(data: Array):
	if data.size() < 2:
		return
	if data[0] in command_list:
		command_list[data[0]].call(data)
	if RUN.has_node("MENU"):
		if data[0] in RUN.get_node("MENU").command_list:
			RUN.get_node("MENU").command_list[data[0]].call(data)
	if RUN.has_node("GAME"):
		if data[0] in RUN.get_node("GAME").command_list:
			RUN.get_node("MENU").command_list[data[0]].call(data)


func send_ms(data: Array):
	if NET.has_node("net_main"):
		NET.get_node("net_main").to_server.rpc_id(1, data)

func send_gs(data: Array):
	if NET.has_node("net_game"):
		NET.get_node("net_game").to_server.rpc_id(1, data)

func save_client_local_logpass():
	ResourceSaver.save(logpass, SAVE_PATH)

func debug_cam():
	if !flag["debug_cam"]:
		print("debug_cam active")
		flag["debug_cam"] = true
		get_tree().root.add_child((preload("res://addons/free_cam/super_cam_2.tscn")).instantiate())
		await get_tree().create_timer(1).timeout
		if get_tree().root.has_node("debug_cam"):
			get_tree().root.get_node("debug_cam").current = true
	else:
		get_tree().root.get_node("debug_cam").queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		flag["debug_cam"] = false
		if Curent_Cam:
			Curent_Cam.current = true

func conn_signal():
	NET.get_node("net_main").main_connected.connect(func():
		pass
		)
	NET.get_node("net_main").main_disconnected.connect(func():
		pass
		)
	
	NET.get_node("net_game").game_connected.connect(func():
		if !RUN.has_node("LOBBY"):
			RUN.add_child(preload("res://scn/LOBBY.tscn").instantiate())
		)
	NET.get_node("net_game").game_disconnected.connect(func():
		if RUN.has_node("LOBBY"):
			RUN.get_node("LOBBY").queue_free()
		if RUN.has_node("GAME"):
			RUN.get_node("GAME").queue_free()
		)
	
	NET.get_node("net_voice").voice_connected.connect(func():
		pass
		)
	NET.get_node("net_voice").voice_disconnected.connect(func():
		pass
		)



func user_list_update(data):
	var serialized = data[1]
	user.clear()
	for d in serialized:
		user.append(AccData.from_dict(d))
	print("Получено пользователей: ", user.size())
	if user.size() > 0:
		pass

func update_avatar(data):
	var username = data[1]
	var avatar_b64 = data[2]
	if !avatar_b64 == null:
		for u in user:
			if u.USERNAME == username:
				u.avatar = AccData.avatar_from_base64(avatar_b64)
				return

func check_avatar(leader_name):
	var data = ["!request_avatar", leader_name]
	send_ms(data)

func update_avatar_in_game(data):
	if data.size() > 0:
		var data2 = data[1]
		if data2.size() > 1:
			var ava_name = data2[1]
			var ava_b64 = data2[2]
			avatar_user[ava_name] = ava_b64
			GAME.ava_update(ava_name)

func send_avatar_to_server(avatar_texture):
	if not avatar_texture:
		return
	var img = avatar_texture.get_image()
	var png_buffer = img.save_png_to_buffer()
	var b64 = Marshalls.raw_to_base64(png_buffer)
	var data = ["!set_avatar", log_in_data["USERNAME"], b64]
	send_ms(data)






























#
