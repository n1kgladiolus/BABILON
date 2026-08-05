extends Control

var settings_window = false

var players_user := {}

var lobby_parametrs = {
	"mode" : "",
	"spawn" : "",
	"koloda" : "",
	"bot" : "",
}

var updating_from_server = false

const king_gerb = [null, null, preload("res://king/gerb/Bear.png"), preload("res://king/gerb/Bull.png"), preload("res://king/gerb/Dragon.png"), preload("res://king/gerb/Eagle.png"), preload("res://king/gerb/Elephant.png"), preload("res://king/gerb/Lion.png")]


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	$Window/Box/Box_menu/Label.text = str(C.lobby_name)
	$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/Label.text = str(C.USERNAME)
	
	#region подключение сигналов кнопок
	$Window/Box/Box_menu/exit_lobby.pressed.connect(_exit_lobby_pressed)
	
	$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.item_selected.connect(king_select.bind(C.USERNAME))
	$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.item_selected.connect(spawn_select.bind(C.USERNAME))
	
	$Window/Box/Box_menu/setting.pressed.connect(_settings)
	
	if C.is_lobby_leader:
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode.disabled = false
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.disabled = false
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/koloda_minus.editable = true
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer3/MarginContainer/VBoxContainer/mode_bot.disabled = false
		
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode.item_selected.connect(p_mode)
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.item_selected.connect(p_mode_start)
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/koloda_minus.value_changed.connect(p_koloda)
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer3/MarginContainer/VBoxContainer/mode_bot.item_selected.connect(p_mode_bot)
		
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer3/MarginContainer/VBoxContainer/START.disabled = false
		$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer3/MarginContainer/VBoxContainer/START.pressed.connect(START_GAME)
	#endregion



#region функции кнопок

func _exit_lobby_pressed():
	C.lobby_disconnect()

func _settings():
	if !settings_window:
		$Window/Box/lobby_window.visible = false
		$Panel.visible = false
		get_tree().current_scene._setting_button()
		get_tree().current_scene.get_node("Window").visible = true
		get_tree().current_scene.get_node("Window").get_node("menu_buttons").visible = false
		get_tree().current_scene.get_node("Window").get_node("menu_fake").visible = true
		get_tree().current_scene.visible = true
		get_tree().current_scene.get_node("Window").get_node("window_func").get_node("setting_panel").visible = true
		get_tree().current_scene.get_node("Window").get_node("window_func").get_node("lobby_panel").visible = false
	else:
		$Window/Box/lobby_window.visible = true
		$Panel.visible = true
		get_tree().current_scene._start_label()
		get_tree().current_scene.get_node("Window").visible = false
		get_tree().current_scene.get_node("Window").get_node("menu_buttons").visible = true
		get_tree().current_scene.get_node("Window").get_node("menu_fake").visible = false
		get_tree().current_scene.visible = false
		
		
		
	
	settings_window = !settings_window

#endregion

func lobby_parametrs_update(data):
	print("lobby_parametrs_update")
	var my_peer_id
	updating_from_server = true
	lobby_parametrs = data[1]
	players_user = data[2]
	
	for yu in players_user:
		if players_user[yu]["username"] == C.USERNAME:
			my_peer_id = yu
	
	for id in players_user.keys():
		if id != my_peer_id and not Audio.players_user_audio.has(id):
			Audio.add_player(id)
			print("audio_user_add")
	
	for id in Audio.players_user_audio.keys():
		if not players_user.has(id):
			Audio.remove_player(id)
			print("audio_user_dell")
	
	
	match lobby_parametrs["mode"]:
		"0":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode.select(0)
		"1":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode.select(1)
	
	match lobby_parametrs["spawn"]:
		"0":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.select(0)
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = true
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = true
			if C.is_lobby_leader:
				$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = false
				$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = false
			
		"1":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.select(1)
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = false
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = false
			
		"2":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.select(2)
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = true
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = true
			
		"3":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.select(3)
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = true
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = false
			
		"4":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/mode_start.select(4)
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = false
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = true
	
	match lobby_parametrs["bot"]:
		"0":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer3/MarginContainer/VBoxContainer/mode_bot.select(0)
		"1":
			$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer3/MarginContainer/VBoxContainer/mode_bot.select(1)
	
	
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/koloda_minus.value = int(lobby_parametrs["koloda"])
	
	
	for child in $Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/other_scroll/other.get_children():
		child.queue_free()
		await get_tree().process_frame
	
	for user in players_user:
		if players_user[user]["username"] == str(C.USERNAME):
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.select(int(players_user[user]["king"]))
			$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.select(int(players_user[user]["spawn"]))
			if C.in_game:
				$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/king_select.disabled = true
				$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/you/Box/spawn_select.disabled = true
			continue
		
		var user_panel = preload("res://lvl/game/players_lobbby_panel.tscn").instantiate()
		await get_tree().process_frame
		user_panel.name = str(user)
		user_panel.custom_minimum_size = Vector2(0, 60)
		$Window/Box/lobby_window/Box_players_list/players_panel/MarginContainer/VBoxContainer/other_scroll/other.add_child(user_panel)
		user_panel.get_node("Box/username").text = str(players_user[user]["username"])
		user_panel.get_node("Box/king_select").select(int(players_user[user]["king"]))
		user_panel.get_node("Box/spawn_select").select(int(players_user[user]["spawn"]))
		if C.in_game:
			user_panel.get_node("Box/king_select").disabled = true
			user_panel.get_node("Box/spawn_select").disabled = true
		user_panel.get_node("Box/voice_volume").change = true
		user_panel.get_node("Box/voice_volume").value = Audio.set_volume_slider(user)
		user_panel.get_node("Box/voice_volume").change = false
		if lobby_parametrs["spawn"] == "0" and C.is_lobby_leader and !C.in_game:
			user_panel.get_node("Box/spawn_select").disabled = false
			user_panel.get_node("Box/king_select").disabled = false
			user_panel.get_node("Box/spawn_select").item_selected.connect(spawn_select.bind(str(user)))
			user_panel.get_node("Box/king_select").item_selected.connect(king_select.bind(str(user)))
	
	icon_spawn_clear()
	for user in players_user:
		if int(players_user[user]["king"]) > 1 and int(players_user[user]["spawn"]) > 1:
			var spawn = int(players_user[user]["spawn"])
			var king = int(players_user[user]["king"])
			icon_spawn_set(spawn, king)
	
	updating_from_server = false
	Audio._connect_all_ui_elements(get_tree().root)

#region параметры лобби
func p_mode(index):
	if updating_from_server:
		return
	lobby_parametrs["mode"] = str(index)
	var data = ["!lobby_parametrs_update", lobby_parametrs]
	C.send_player_command(data)

func p_mode_start(index):
	if updating_from_server:
		return
	lobby_parametrs["spawn"] = str(index)
	var data = ["!lobby_parametrs_update", lobby_parametrs]
	C.send_player_command(data)

func p_koloda(value):
	if updating_from_server:
		return
	lobby_parametrs["koloda"] = str(value)
	var data = ["!lobby_parametrs_update", lobby_parametrs]
	C.send_player_command(data)

func p_mode_bot(index):
	if updating_from_server:
		return
	lobby_parametrs["bot"] = str(index)
	var data = ["!lobby_parametrs_update", lobby_parametrs]
	C.send_player_command(data)



#endregion

#region параметры игроков
func spawn_select(index, user):
	if str(user) == C.USERNAME:
		for u in players_user:
			if players_user[u]["username"] == str(C.USERNAME):
				players_user[u]["spawn"] = str(index)
				var data = ["!lobby_parametrs_user_update", players_user]
				C.send_player_command(data)
				return
	if C.is_lobby_leader:
		players_user[int(user)]["spawn"] = str(index)
		var data = ["!lobby_parametrs_user_update", players_user]
		C.send_player_command(data)

func king_select(index, user):
	if str(user) == C.USERNAME:
		for u in players_user:
			if players_user[u]["username"] == str(C.USERNAME):
				players_user[u]["king"] = str(index)
				var data = ["!lobby_parametrs_user_update", players_user]
				C.send_player_command(data)
				return
	if C.is_lobby_leader:
		players_user[int(user)]["king"] = str(index)
		var data = ["!lobby_parametrs_user_update", players_user]
		C.send_player_command(data)




#endregion

func START_GAME():
	var data = ["!START_GAME"]
	C.send_player_command(data)

func icon_spawn_clear():
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control1/king.texture = null
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control2/king.texture = null
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control3/king.texture = null
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control4/king.texture = null
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control5/king.texture = null
	$Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control6/king.texture = null

func icon_spawn_set(spawn, king):
	match spawn:
		2 : $Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control1/king.texture = king_gerb[king]
		3 : $Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control2/king.texture = king_gerb[king]
		4 : $Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control3/king.texture = king_gerb[king]
		5 : $Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control4/king.texture = king_gerb[king]
		6 : $Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control5/king.texture = king_gerb[king]
		7 : $Window/Box/lobby_window/Box_players_list/parametrs_panel/HBoxContainer/VBoxContainer2/MarginContainer/TextureRect/Control6/king.texture = king_gerb[king]
		












#
