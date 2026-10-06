extends Node

var NET
var RUN
var GAME
var MENU

var count_user := 0

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var port
	for a in args:
		if a.begins_with("--port="):
			port = a.get_slice("=", 1).to_int()
	NET = R.NET
	if has_node("/root/RUN"):
		RUN = get_node("/root/RUN")
	else:
		get_tree().quit()
	var dead_timer = Timer.new()
	dead_timer.name = "dead_timer"
	dead_timer.wait_time = 20
	dead_timer.one_shot = false
	dead_timer.autostart = true
	dead_timer.timeout.connect(func():
		if count_user == 0:
			print("игроков нет, конец")
			get_tree().quit()
		)
	await get_tree().process_frame
	RUN.add_child(dead_timer)
	var data = ["lobby_start_ok", port]
	send_main_server(data)
	NET.get_node("net_game").peer_connected.connect(func():
		count_user += 1
		)
	NET.get_node("net_game").peer_disconnected.connect(func():
		count_user -= 1
		)

func _process(delta: float) -> void:
	pass

func send_main_server(data: Array):
	if R.NET.has_node("net_main"):
		R.NET.get_node("net_main").to_server.rpc(data)

func send_all(data: Array):
	if R.NET.has_node("net_game"):
		R.NET.get_node("net_game").from_server.rpc(data)

func send_id(id, data: Array):
	if R.NET.has_node("net_game"):
		R.NET.get_node("net_game").from_server.rpc_id(id, data)

func command(sender_id: int, data: Array):
	pass
