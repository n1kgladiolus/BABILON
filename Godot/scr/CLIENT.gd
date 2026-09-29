extends Node

var NET
var RUN

@export var flag: Dictionary[String, bool] = {
	"debug_cam" : false,
	"in_menu" : false,
	"in_game" : false,
	"server_connect" : false,
	}


func _ready() -> void:
	NET = R.NET
	if has_node("/root/RUN"):
		RUN = get_node("/root/RUN")
	if RUN:
		conn_signal()

func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("debug_cam"):
		debug_cam()


func command(data):
	pass


func send_ms(data: Dictionary):
	if get_tree().root.has_node("net_main"):
		R.NET.get_node("net_main").to_server.rpc_id(1, data)

func send_gs(data: Dictionary):
	if get_tree().root.has_node("net_game"):
		R.NET.get_node("net_game").to_server.rpc_id(1, data)


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

func conn_signal():
	NET.get_node("net_main").main_connected.connect(func():
		if !RUN.has_node("MENU"):
			RUN.add_child(preload("res://scn/MENU.tscn").instantiate())
		)
	NET.get_node("net_main").main_disconnected.connect(func():
		if RUN.has_node("MENU"):
			RUN.get_node("MENU").queue_free()
		)
	
	NET.get_node("net_game").game_connected.connect(func():
		if !RUN.has_node("LOBBY"):
			RUN.add_child(preload("res://scn/LOBBY.tscn").instantiate())
		)
	NET.get_node("net_game").game_disconnected.connect(func():
		if RUN.has_node("LOBBY"):
			RUN.get_node("LOBBY").queue_free()
		)
	
	NET.get_node("net_voice").voice_connected.connect(func():
		pass
		)
	NET.get_node("net_voice").voice_disconnected.connect(func():
		pass
		)

































#
