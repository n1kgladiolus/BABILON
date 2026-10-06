extends Node

@export var version = ProjectSettings.get_setting("application/config/version", "0.0.1")
@export var mode := "" #CLIENT, SERVER, SERVER_GAME


var NET:  Node



func _ready() -> void:
	OS.add_logger(preload("res://addons/log/custom_log.gd").new())
	print("Hello Programm!")
	await get_tree().process_frame
	start()


func start():
	var args := OS.get_cmdline_user_args()
	if "--SERVER" in args:
		mode = "SERVER"
		IL.set_role_id("server")
	elif "--SERVER_GAME" in args:
		mode = "SERVER_GAME"
		IL.set_role_id("server_game")
	else:
		mode = "CLIENT"
		IL.set_role_id("client")
	
	await get_tree().process_frame
	
	print("Версия: " + str(version))
	print("Аргументы: " + str(args))
	print("Режим: " + str(mode))
	
	NET = preload("res://scn/NET.tscn").instantiate()
	get_tree().root.add_child(NET)
	await get_tree().process_frame
	_boot(args)


func _boot(args):
	match mode:
		"SERVER":
			NET.get_node("net_main").setup("server", {"port": 6767})
			var s := preload("res://scr/SERVER.gd").new()
			s.name = "SERVER"
			get_tree().root.add_child(s)
		"SERVER_GAME":
			var port
			for a in args:
				if a.begins_with("--port="):
					port = a.get_slice("=", 1).to_int()
			NET.get_node("net_main").setup("client", {"url": "ws://188.168.138.144:6767"})
			await get_tree().process_frame
			NET.get_node("net_game").setup("server", {"port": port})
			NET.get_node("net_voice").setup("server", {"port": port+1})
			var sg := preload("res://scr/SERVER_GAME.gd").new()
			sg.name = "SERVER_GAME"
			get_tree().root.add_child(sg)
		"CLIENT":
			get_tree().root.add_child(preload("res://scn/game_scn/post_proccess.tscn").instantiate())
			await get_tree().process_frame
			NET.get_node("net_main").setup("client", {"url": "ws://188.168.138.144:6767"})
			var c := preload("res://scr/CLIENT.gd").new()
			c.name = "CLIENT"
			get_tree().root.add_child(c)
