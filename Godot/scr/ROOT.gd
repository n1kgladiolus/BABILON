extends Node
var RN
@export var version = ProjectSettings.get_setting("application/config/version", "0.0.1")
@export var mode := "" #CLIENT, SERVER, SERVER_GAME
@export var root_flag: Dictionary[String, bool] = {
	"debug_cam" : false,
	"in_menu" : false,
	"in_game" : false,
	"server_connect" : false,
	}



func _ready() -> void:
	print("Hello Programm!")
	await get_tree().process_frame
	start()

func _input(event):
	if event.is_action_pressed("debug_cam"):
		debug_cam()




func start():
	RN = get_tree().get_current_scene()
	var args := OS.get_cmdline_user_args()
	if "--SERVER" in args:
		mode = "SERVER"
	elif "--SERVER_GAME" in args:
		mode = "SERVER_GAME"
	else:
		mode = "CLIENT"
		client_start()
	
	print("Версия: ", version)
	print("Аргументы: ", args)
	print("Режим: ", mode)


func client_start():
	get_tree().root.add_child((preload("res://scn/NET.tscn")).instantiate())
	await get_tree().process_frame
	#RN.add_child((preload("res://scn/MENU.tscn")).instantiate())
	pass


func debug_cam():
	if !root_flag["debug_cam"]:
		print("debug_cam active")
		root_flag["debug_cam"] = true
		RN.add_child((preload("res://addons/free_cam/super_cam_2.tscn")).instantiate())
		await get_tree().create_timer(1).timeout
		if RN.has_node("debug_cam"):
			RN.get_node("debug_cam").current = true
	else:
		RN.get_node("debug_cam").queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		root_flag["debug_cam"] = false




























#
