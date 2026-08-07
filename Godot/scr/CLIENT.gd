extends Node

const DISCO_ELYSIUM = preload("res://ost/music/disco_elysium.mp3")
const OST_1 = preload("res://ost/music/ost_1.mp3")
const playlist_in_game = preload("res://ost/playlist_in_game.tres")

var DEBUG = false # true false

var SETTINGS
var controls_data

var base_path = OS.get_executable_path().get_base_dir()
var SAVE_PATH = base_path.path_join("client_local_logpass.tres")
var logpass: client_local_logpass
var USERNAME: String = ""
var PASSWORD: String = ""

const ADRESS = "ws://188.168.138.144:"
var PEER
var VOICE

var lobby_list
var in_lobby := false
var is_lobby_leader := false
var in_game := false

var log_in_status := false
var connect_status := false
var user: Array[AccData] = []
var log_in_errors := ""

var mic_settings = []

var lobby_name
var lobby_scene
var game_scene
var avatar_user := {}

var user_command = {
	"!log_in_password_invalid" : log_in_password_invalid,
	"!log_in_version_client_invalid" : log_in_version_client_invalid,
	"!log_in_success" : log_in_success,
	"!log_in_online_invalid" : log_in_online_invalid,
	"!user_list_update" : user_list_update,
	"!update_avatar" : update_avatar,
	"!lobby_list_update" : lobby_list_update,
	"!lobby_connect" : lobby_connect,
	"!lobby_connect_error" : lobby_connect_error,
	"!check_user_in_lobby" : check_user_in_lobby,
	"!lobby_parametrs_update" : lobby_parametrs_update,
	"!START_GAME" : START_GAME,
	"!update_avatar_in_game" : update_avatar_in_game,
	"!COOP_ERROR" : coop_error,
}

func _input(event: InputEvent):
	if event.is_action_pressed("esc") and in_game and !game_scene.buy_flag and !game_scene.rotate_system_active:
		if lobby_scene.visible == false:
			lobby_scene.visible = true
		elif lobby_scene.visible == true:
			lobby_scene.visible = false
			lobby_scene.settings_window = true
			lobby_scene._settings()
	
	if event.is_action_pressed("voice"):
		mic_settings[2].set_pressed(true)
	elif event.is_action_released("voice"):
		mic_settings[2].set_pressed(false)

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--server" in args or "--server_game" in args:
		queue_free()
		return
	else:
		R.status = "CLIENT"
		pass
	print("Запущен в режиме КЛИЕНТА")
	PEER = WebSocketMultiplayerPeer.new()
	if PEER.create_client(ADRESS+"6767") != OK:
		print("Ошибка подключения к серверу")
		return
	multiplayer.multiplayer_peer = PEER
	multiplayer.connected_to_server.connect(server_connect)
	multiplayer.server_disconnected.connect(server_disconnect)
	multiplayer.connection_failed.connect(server_connect_failed)
	
	if ResourceLoader.exists(SAVE_PATH):
		logpass = ResourceLoader.load(SAVE_PATH) as client_local_logpass
		USERNAME = logpass.USERNAME
		PASSWORD = logpass.PASSWORD
		SETTINGS = logpass.SETTINGS
		controls_data = logpass.controls_data
		logpass.apply_to_input_map()
	else:
		logpass = client_local_logpass.new()
		_save_client_local_logpass()
	
	await get_tree().process_frame
	if !DEBUG:
		get_tree().call_deferred("change_scene_to_file", "res://lvl/menu/menu.tscn")

func _save_client_local_logpass():
	ResourceSaver.save(logpass, SAVE_PATH)

func server_connect():
	print("Успешное подключение")
	connect_status = true

func server_connect_failed():
	print("Ошибка подключения")
	lobby_disconnect()

func server_disconnect():
	print("Отключение от сервера")
	connect_status = false

func send_player_command(data):
	if multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() == 2:
		R.rpc_id(1, "send_player_command", data)

func log_in_success(data):
	log_in_status = true

func log_in_password_invalid(data):
	log_in_errors = "Неверный пароль"

func log_in_version_client_invalid(data):
	log_in_errors = "Ваша версия игры устарела"

func log_in_online_invalid(data):
	log_in_errors = "Такой пользователь уже в сети"


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
	send_player_command(data)

func send_avatar_to_server(avatar_texture):
	if not avatar_texture:
		return
	var img = avatar_texture.get_image()
	var png_buffer = img.save_png_to_buffer()
	var b64 = Marshalls.raw_to_base64(png_buffer)
	send_player_command(["!set_avatar", USERNAME, b64])


func lobby_list_update(data):
	lobby_list = data[1]
	print("Список лобби: ")
	print(lobby_list)


func lobby_connect(data):
	var port = data[1]
	lobby_name = data[2]
	#send_player_command(["!connect_user_lobby"])
	#await get_tree().process_frame
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	PEER = WebSocketMultiplayerPeer.new()
	if PEER.create_client(ADRESS+str(port)) != OK:
		print("Ошибка подключения к лобби")
		return
	multiplayer.multiplayer_peer = PEER
	#multiplayer.connected_to_server.connect(server_connect)
	#multiplayer.server_disconnected.connect(server_disconnect)
	#multiplayer.connection_failed.connect(server_connect_failed)
	await get_tree().process_frame
	get_tree().current_scene.visible = false
	var lobby_node = preload("res://lvl/game/lobby.tscn").instantiate()
	get_tree().root.add_child(lobby_node)
	lobby_scene = get_tree().root.get_node("Lobby")
	#get_tree().call_deferred("change_scene_to_file", "res://lvl/game/lobby.tscn")
	await get_tree().process_frame
	in_lobby = true
	Audio._connect_all_ui_elements(get_tree().root)


func lobby_connect_error(data):
	in_lobby = false

func lobby_disconnect():
	if in_game:
		get_tree().root.get_node("GAME").queue_free()
		in_game = false
	await get_tree().process_frame
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		
	PEER = WebSocketMultiplayerPeer.new()
	if PEER.create_client(ADRESS+"6767") != OK:
		print("Ошибка подключения к лобби")
		return
	multiplayer.multiplayer_peer = PEER
	
	if in_lobby:
		await get_tree().process_frame
		get_tree().current_scene.visible = true
		get_tree().current_scene.get_node("Window").visible = true
		get_tree().current_scene._start_label()
		get_tree().current_scene.get_node("Window").get_node("menu_buttons").visible = true
		get_tree().current_scene.get_node("Window").get_node("menu_fake").visible = false
		get_tree().root.get_node("Lobby").queue_free()
		in_lobby = false
		is_lobby_leader = false
	
	
	
	Audio.get_node("Background").set_stream(OST_1)
	Audio.get_node("Background").play()
	Audio.get_node("Background_veter").stop()
	Console.get_node("Background").visible = true

func check_user_in_lobby(data):
	if in_lobby == true:
		if USERNAME == str(data[1]):
			is_lobby_leader = true
		data = ["!check_user_in_lobby_return",USERNAME]
		send_player_command(data)

func lobby_parametrs_update(data):
	print(data)
	lobby_scene.lobby_parametrs_update(data)



func START_GAME(data):
	in_game = true
	await get_tree().process_frame
	var game_node = preload("res://lvl/game/game.tscn").instantiate()
	get_tree().root.add_child(game_node)
	game_scene = get_tree().root.get_node("GAME")
	lobby_scene.get_node("Window").get_node("Box").get_node("lobby_window").get_node("Box_players_list").get_node("parametrs_panel").visible = false
	lobby_scene.get_node("Window").get_node("Box").get_node("lobby_window").get_node("Box_players_list").get_node("parametrs_label").visible = false
	lobby_scene.get_node("Window").get_node("Box").get_node("lobby_window").get_node("Box_players_list").get_node("Sep4").visible = false
	Console.get_node("Background").visible = false
	lobby_scene.visible = false
	
	(get_tree().root).move_child(lobby_scene, (get_tree().root).get_child_count() - 1)
	(get_tree().root).move_child(get_tree().current_scene, (get_tree().root).get_child_count() - 2)
	await get_tree().process_frame
	Audio._connect_all_ui_elements(get_tree().root)
	Audio.get_node("Background").set_stream(playlist_in_game)
	Audio.get_node("Background").play()
	Audio.get_node("Background_veter").play()


func update_avatar_in_game(data):
	if data.size() > 0:
		var data2 = data[1]
		if data2.size() > 1:
			var ava_name = data2[1]
			var ava_b64 = data2[2]
			avatar_user[ava_name] = ava_b64
			game_scene.ava_update(ava_name)

func coop_error(data):
	lobby_scene.coop_error()

















#
