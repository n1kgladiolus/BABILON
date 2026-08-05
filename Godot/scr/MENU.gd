extends Node
var M_BEAR = preload("res://visual/material/king/mBear.tres")
var M_BULL = preload("res://visual/material/king/mBull.tres")
var M_DRAGON = preload("res://visual/material/king/mDragon.tres")
var M_EAGLE = preload("res://visual/material/king/mEagle.tres")
var M_ELEPHANT = preload("res://visual/material/king/mElephant.tres")
var M_LION = preload("res://visual/material/king/mLion.tres")

var lobby_port_selected
var lobby_name_selected

var waiting_action: String = ""

func _ready() -> void:
	if !C.log_in_status:
		$Window.visible = false
	
	#region материалы
	M_BEAR.albedo_color = C.logpass.SETTINGS["COLOR_DED"]["mBear"]
	M_BULL.albedo_color = C.logpass.SETTINGS["COLOR_DED"]["mBull"]
	M_DRAGON.albedo_color = C.logpass.SETTINGS["COLOR_DED"]["mDragon"]
	M_EAGLE.albedo_color = C.logpass.SETTINGS["COLOR_DED"]["mEagle"]
	M_ELEPHANT.albedo_color = C.logpass.SETTINGS["COLOR_DED"]["mElephant"]
	M_LION.albedo_color = C.logpass.SETTINGS["COLOR_DED"]["mLion"]
	#endregion
	
	#region подключение сигналов кнопок
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Master.value_changed.connect(_Sound_edit.bind("Master"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Background.value_changed.connect(_Sound_edit.bind("Background"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Action.value_changed.connect(_Sound_edit.bind("Action"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Voice.value_changed.connect(_Sound_edit.bind("VOICE"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Veter.value_changed.connect(_Sound_edit.bind("Veter"))
	
	
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/buttons/Dragon.color_changed.connect(_ded_mode_set_color.bind("Dragon"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/buttons/Bear.color_changed.connect(_ded_mode_set_color.bind("Bear"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/buttons/Bull.color_changed.connect(_ded_mode_set_color.bind("Bull"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/buttons/Elephant.color_changed.connect(_ded_mode_set_color.bind("Elephant"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/buttons/Lion.color_changed.connect(_ded_mode_set_color.bind("Lion"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/buttons/Eagle.color_changed.connect(_ded_mode_set_color.bind("Eagle"))
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/buttons_settting/VBoxContainer/DedMode.pressed.connect(_ded_mode)
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG.confirmed.connect(_ded_mode_set_ok)
	
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG/box/username.text = C.USERNAME
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG/box/password.text = C.PASSWORD
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG/box/username.text_changed.connect(_username_changed)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG/box/password.text_changed.connect(_password_changed)
	
	$Window/menu_buttons/lobby.pressed.connect(_lobby_button)
	$Window/menu_buttons/account.pressed.connect(_account_button)
	$Window/menu_buttons/setting.pressed.connect(_setting_button)
	$Window/menu_buttons/autor.pressed.connect(_autor__button)
	$Window/menu_buttons/rules.pressed.connect(_rules_button)
	$Window/menu_buttons/exit.pressed.connect(_exit_button)
	
	
	$Window/window_func/lobby_panel/MarginContainer/Box/create/Box/create_lobby_button.pressed.connect(_create_lobby)
	
	
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/user_avatar/avatar_button.pressed.connect(_avatar_button)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/relog_acc.pressed.connect(_relog_acc_button)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.confirmed.connect(_log_in_dialog)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.canceled.connect(_exit_button)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.close_requested.connect(_log_in_dialog_cancel)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/AVATAR_DIALOG.file_selected.connect(_avatar_dialog)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.confirmed.connect(_log_in_error)
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.close_requested.connect(_log_in_error)
	
	
	if !C.log_in_status:
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.popup()
	
	
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.item_selected.connect(_leader_board_select)
	$Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.item_activated.connect(_lobby_select)
	
	
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.close_requested.connect(_wait_log_dialog)
	
	$Window/window_func/lobby_panel/MarginContainer/Box/JOIN_LOBBY_PASSWORD.confirmed.connect(_lobby_join)
	
	
	#endregion
	#region микрофон
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/MicOnButton.pressed.connect(_microfone_edit)
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/PTTEdit.pressed.connect(_ptt_edit)
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/VoxButton.pressed.connect(_vox_edit)
	C.mic_settings.append($Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/MicOnButton)
	C.mic_settings.append($Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/InputOptionButton)
	C.mic_settings.append($Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/PTTButton)
	C.mic_settings.append($Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/VoxButton)
	C.mic_settings.append($Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/DenoiseButton)
	C.mic_settings.append($Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/FeedbackDisplay)
	#endregion
	#region настройки
	
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/PTTEdit.text = C.logpass.SETTINGS["PTT_BUTTON_NAME"]
	if C.logpass.SETTINGS["VOX_MODE"] == "OFF":
		$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/VoxButton.button_pressed = false
	if C.logpass.SETTINGS["MICROFONE"] == "OFF":
		$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/MicOnButton.button_pressed = false
	
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Master.value = C.logpass.SETTINGS["S_Master"]
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Background.value = C.logpass.SETTINGS["S_Background"]
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Action.value = C.logpass.SETTINGS["S_Action"]
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Voice.value = C.logpass.SETTINGS["S_Voice"]
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Veter.value = C.logpass.SETTINGS["S_Veter"]
	#endregion

#region кнопки

func _input(event: InputEvent):
	if waiting_action == "":
		return
	if not event.is_pressed() or event.is_echo():
		return
	if not (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		return
	InputMap.action_erase_events(waiting_action)
	InputMap.action_add_event(waiting_action, event)
	
	var action = waiting_action
	var keyname
	if event is InputEventKey:
		keyname = OS.get_keycode_string(event.get_key_label_with_modifiers())
	waiting_action = ""
	
	if action == "voice":
		$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/PTTEdit.text = str(keyname)
		C.logpass.capture_from_input_map()
		C.logpass.SETTINGS["PTT_BUTTON_NAME"] = str(keyname)
	
	C._save_client_local_logpass()

func _lobby_button():
	$Window/window_func/start_label.visible = false
	
	$Window/window_func/lobby_panel/MarginContainer/Box/create/Box/lobbyname.text = "Стол " + C.USERNAME
	$Window/window_func/lobby_panel.visible = true
	$Window/window_func/account_panel.visible = false
	$Window/window_func/setting_panel.visible = false
	$Window/window_func/author_panel.visible = false
	$Window/window_func/rules_panel.visible = false
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/color_flag_scene/ded_scene.visible = false
	_lobby_list_update_menu()

func _account_button():
	$Window/window_func/start_label.visible = false
	
	$Window/window_func/lobby_panel.visible = false
	$Window/window_func/account_panel.visible = true
	$Window/window_func/setting_panel.visible = false
	$Window/window_func/author_panel.visible = false
	$Window/window_func/rules_panel.visible = false
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/color_flag_scene/ded_scene.visible = false
	_update_menu_user_data()

func _setting_button():
	$Window/window_func/start_label.visible = false
	
	$Window/window_func/lobby_panel.visible = false
	$Window/window_func/account_panel.visible = false
	$Window/window_func/setting_panel.visible = true
	$Window/window_func/author_panel.visible = false
	$Window/window_func/rules_panel.visible = false
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/color_flag_scene/ded_scene.visible = true

func _autor__button():
	$Window/window_func/start_label.visible = false
	
	$Window/window_func/lobby_panel.visible = false
	$Window/window_func/account_panel.visible = false
	$Window/window_func/setting_panel.visible = false
	$Window/window_func/author_panel.visible = true
	$Window/window_func/rules_panel.visible = false
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/color_flag_scene/ded_scene.visible = false

func _rules_button():
	$Window/window_func/start_label.visible = false
	
	$Window/window_func/lobby_panel.visible = false
	$Window/window_func/account_panel.visible = false
	$Window/window_func/setting_panel.visible = false
	$Window/window_func/author_panel.visible = false
	$Window/window_func/rules_panel.visible = true
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/color_flag_scene/ded_scene.visible = false

func _start_label():
	$Window/window_func/start_label.visible = true
	$Window/window_func/lobby_panel.visible = false
	$Window/window_func/account_panel.visible = false
	$Window/window_func/setting_panel.visible = false
	$Window/window_func/author_panel.visible = false
	$Window/window_func/rules_panel.visible = false
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG/color_flag/color_flag_scene/ded_scene.visible = false


func _exit_button():
	get_tree().quit()

func _ptt_edit():
	if waiting_action != "":
		return
	waiting_action = "voice"
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/PTTEdit.text = "нажмите кнопку..."

func _vox_edit():
	if $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/VoxButton.button_pressed:
		C.logpass.SETTINGS["VOX_MODE"] = "ON"
	else:
		C.logpass.SETTINGS["VOX_MODE"] = "OFF"
	C._save_client_local_logpass()

func _microfone_edit():
	if $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer/MicOnButton.button_pressed:
		C.logpass.SETTINGS["MICROFONE"] = "ON"
	else:
		C.logpass.SETTINGS["MICROFONE"] = "OFF"
	C._save_client_local_logpass()

func _Sound_edit(value, bus):
	var bus_index = AudioServer.get_bus_index(bus)
	if value < -28:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, value)
	match bus:
		"Master" : C.logpass.SETTINGS["S_Master"] = $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Master.value
		"Background" : C.logpass.SETTINGS["S_Background"] = $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Background.value
		"VOICE" : C.logpass.SETTINGS["S_Voice"] = $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Voice.value
		"Action" : C.logpass.SETTINGS["S_Action"] = $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Action.value
		"Veter" : C.logpass.SETTINGS["S_Veter"] = $Window/window_func/setting_panel/MarginContainer/TabContainer/setting_main/MarginContainer/HBoxContainer/VBoxContainer2/Ss_Veter.value
	
	C._save_client_local_logpass()

func _ded_mode_set_color(color, king):
	match king:
		"Dragon" : M_DRAGON.albedo_color = color
		"Bear" : M_BEAR.albedo_color = color
		"Bull" : M_BULL.albedo_color = color
		"Elephant" : M_ELEPHANT.albedo_color = color
		"Lion" : M_LION.albedo_color = color
		"Eagle" : M_EAGLE.albedo_color = color
		_ : pass

func _ded_mode():
	$Window/window_func/setting_panel/MarginContainer/TabContainer/setting_dop/DED_DIALOG.popup()

func _ded_mode_set_ok():
	C.logpass.SETTINGS["COLOR_DED"]["mBear"] = Color(M_BEAR.albedo_color)
	C.logpass.SETTINGS["COLOR_DED"]["mBull"] = Color(M_BULL.albedo_color)
	C.logpass.SETTINGS["COLOR_DED"]["mDragon"] = Color(M_DRAGON.albedo_color)
	C.logpass.SETTINGS["COLOR_DED"]["mEagle"] = Color(M_EAGLE.albedo_color)
	C.logpass.SETTINGS["COLOR_DED"]["mElephant"] = Color(M_ELEPHANT.albedo_color)
	C.logpass.SETTINGS["COLOR_DED"]["mLion"] = Color(M_LION.albedo_color)
	C._save_client_local_logpass()
#endregion


func _avatar_button():
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/AVATAR_DIALOG.popup()

func _relog_acc_button():
	$Window.visible = false
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.popup()

func _log_in_dialog():
	if len(C.USERNAME) > 3 and len(C.USERNAME) < 18 :
		if len(C.PASSWORD) > 3 and len(C.PASSWORD) < 18:
			_wait_log_dialog()
			C.logpass.USERNAME = C.USERNAME
			C.logpass.PASSWORD = C.PASSWORD
			C._save_client_local_logpass()
			var data = ["!log_acc", C.USERNAME, C.PASSWORD, R.version]
			C.send_player_command(data)
			await get_tree().create_timer(0.5).timeout
			if C.log_in_status:
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.hide()
				$Window.visible = true
				_update_menu_user_data()
				Audio.get_node("Background").play()
			else:
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.hide()
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.hide()
				await get_tree().process_frame
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.dialog_text = str(C.log_in_errors)
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.popup()
				return
		else:
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.hide()
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.hide()
			await get_tree().process_frame
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.dialog_text = "Короткий или длинный пароль"
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.popup()
			return
	else:
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.hide()
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.hide()
		await get_tree().process_frame
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.dialog_text = "Короткий или длинный никнейм"
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.popup()
		return

func _username_changed(text):
	C.USERNAME = str(text)

func _password_changed(text):
	C.PASSWORD = str(text)

func _wait_log_dialog():
	await get_tree().process_frame
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.hide()
	await get_tree().process_frame
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.popup()

func _log_in_error():
	await get_tree().process_frame
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.popup()

func _log_in_dialog_cancel():
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.hide()
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/WAIT.hide()
	await get_tree().process_frame
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/LOG_IN_DIALOG.popup()

func _avatar_dialog(path: String):
	var ava_image = Image.load_from_file(path)
	if ava_image == null:
		print("Ошибка загрузки изображения")
		return
	ava_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	var ava_texture = ImageTexture.create_from_image(ava_image)
	C.send_avatar_to_server(ava_texture)
	await get_tree().create_timer(1.0).timeout
	_update_menu_user_data()

func _leader_board_select():
	var selected = $Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.get_selected()
	if selected:
		var leader_board_user_selected = selected.get_text(0)
		C.check_avatar(leader_board_user_selected)
		await get_tree().create_timer(0.2).timeout
		_update_menu_leader_data(leader_board_user_selected)



func _update_menu_user_data():
	var data = ["!user_list_update", C.USERNAME]
	C.send_player_command(data)
	await get_tree().create_timer(0.5).timeout
	data = ["!request_avatar", C.USERNAME]
	C.send_player_command(data)
	await get_tree().create_timer(0.5).timeout
	
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.clear()
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.set_column_title(0, "Имя")
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.set_column_title(1, "Ранг")
	
	var root_leader = $Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.create_item()
	
	$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/username_label.text = C.USERNAME
	
	C.user.sort_custom(func(a, b): return a.SCOPE > b.SCOPE)
	
	for u in C.user:
		
		var item = $Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/leader_board.create_item(root_leader)
		item.set_text(0, str(u.USERNAME))
		item.set_text(1, str(u.SCOPE))
		
		item.set_text_alignment(0, 1)
		item.set_text_alignment(1, 1)
		
		if u.USERNAME == C.USERNAME:
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/scope.text = "РАНГ: " + str(u.SCOPE)
			if !u.avatar == null:
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/user_avatar.texture = u.avatar
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/part.text = "Партий: " + str(u.PART)
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box/clan.text = "Клан: " + str(u.CLANTEG)
	Audio._connect_all_ui_elements(get_tree().root)

func _update_menu_leader_data(leader):
	for u in C.user:
		if u.USERNAME == str(leader):
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box2/username_label.text = u.USERNAME
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box2/part.text = "Партий: " + str(u.PART)
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box2/clan.text = "Клан: " + str(u.CLANTEG)
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box2/scope.text = "РАНГ: " + str(u.SCOPE)
			$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box2/user_avatar.texture = u.avatar
			if u.avatar == null:
				$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/box2/user_avatar.texture = preload("res://import/ava_placehold.png")
			
	Audio._connect_all_ui_elements(get_tree().root)

func _lobby_list_update_menu():
	var data = ["!lobby_list_update"]
	C.send_player_command(data)
	await get_tree().create_timer(0.5).timeout
	$Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.clear()
	$Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.set_column_title(0, "Имя стола")
	$Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.set_column_title(1, "Игроков")
	$Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.set_column_title(2, "Статус")
	
	var root_lobby = $Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.create_item()
	
	for l in C.lobby_list:
		var item = $Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.create_item(root_lobby)
		item.set_text(0, str(l["name"]))
		item.set_metadata(0, l["port"])
		item.set_text(1, str(l["players_count"]))
		item.set_text(2, str(l["status"]))
		
		item.set_text_alignment(0, 1)
		item.set_text_alignment(1, 1)
		item.set_text_alignment(2, 1)
	
	Audio._connect_all_ui_elements(get_tree().root)

func _lobby_select():
	var selected = $Window/window_func/lobby_panel/MarginContainer/Box/lobby_list.get_selected()
	if selected:
		lobby_port_selected = selected.get_metadata(0)
		lobby_name_selected = selected.get_text(0)
		if selected.get_text(2) != "in_game":
			$Window/window_func/lobby_panel/MarginContainer/Box/JOIN_LOBBY_PASSWORD.popup()


func _lobby_join():
	var lobby_password = str($Window/window_func/lobby_panel/MarginContainer/Box/JOIN_LOBBY_PASSWORD/password_join.text)
	var data = ["!lobby_connect_request", lobby_port_selected, lobby_name_selected, lobby_password]
	C.send_player_command(data)

func _create_lobby():
	var new_lobby_name = $Window/window_func/lobby_panel/MarginContainer/Box/create/Box/lobbyname.text
	var new_lobby_password = $Window/window_func/lobby_panel/MarginContainer/Box/create/Box/lobbypass.text
	var data = ["!lobby_new_create", str(new_lobby_name), str(new_lobby_password), C.USERNAME]
	C.send_player_command(data)
	$Window.visible = false
	await get_tree().create_timer(6.0).timeout
	if C.in_lobby == false:
		$Window.visible = true
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.dialog_text = "Ошибка создания лобби"
		$Window/window_func/account_panel/MarginContainer/TabContainer/Account/box/ERROR_LOG_IN_DIALOG.popup()
























#
