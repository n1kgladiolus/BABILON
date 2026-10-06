extends Node

@onready var Nlist: Array[Node] = [
	$UI/mainbox/mainbox2/Menu/Menu/Container/username,
	$UI/mainbox/mainbox2/Menu/Menu/Container/pass,
	$UI/mainbox/mainbox2/Menu/Menu/Container/log_in,
	$UI/mainbox/mainbox2/Menu/Menu/Container/log_in_errors,
	$UI/mainbox/mainbox2/Menu/Menu/Container/lobby_list,
	$UI/mainbox/mainbox2/Menu/Menu/Container/profile,
	$UI/mainbox/mainbox2/Menu/Menu/Container/settings,
	$UI/mainbox/mainbox2/Menu/Menu/Container/autors,
	$UI/mainbox/mainbox2/Menu/Menu/Container/rules,
	$UI/mainbox/mainbox2/Menu/Menu/Container/exit,
	$UI/mainbox/mainbox2/Menu/Menu/Container/Timer,
	$UI/mainbox/mainbox2/Window/Panel/Panel/lobby_list,
	$UI/mainbox/mainbox2/Window/Panel/Panel/profile,
	$UI/mainbox/mainbox2/Window/Panel/Panel/settings,
	$UI/mainbox/mainbox2/Window/Panel/Panel/autors,
	$UI/mainbox/mainbox2/Window/Panel/Panel/rules,
	
	]

@onready var king_material: Dictionary = {
	"M_BEAR" : preload("res://visual/material/establishment/mBear.tres"),
	"M_BULL" : preload("res://visual/material/establishment/mBull.tres"),
	"M_DRAGON" : preload("res://visual/material/establishment/mDragon.tres"),
	"M_EAGLE" : preload("res://visual/material/establishment/mEagle.tres"),
	"M_ELEPHANT" : preload("res://visual/material/establishment/mElephant.tres"),
	"M_LION" : preload("res://visual/material/establishment/mLion.tres")
	} 

var command_list: Dictionary = {
	"client_log_in" : client_log_in,
	}


var NET
var RUN
var CLIENT

func _ready() -> void:
	NET = R.NET
	RUN = get_node("/root/RUN")
	CLIENT = get_node("/root/CLIENT")
	debug_buttons()
	$World.get_node("environment").to_night(0)
	buttons()
	CLIENT.log_in_data["VERSION"] = ProjectSettings.get_setting("application/config/version", "1.0.0")
	set_king_material()


func _process(delta: float) -> void:
	pass

func send_ms(data: Array):
	if NET.has_node("net_main"):
		NET.get_node("net_main").to_server.rpc_id(1, data)


func debug_buttons():
	await get_tree().process_frame
	if RUN:
		RUN.get_node("full_black").queue_free()
	$debug/Container/log_in.pressed.connect(func():
		NET.get_node("net_game").setup("client", {"url": "ws://188.168.138.144:6769"})
		NET.get_node("net_voice").setup("client", {"url": "ws://188.168.138.144:6770"})
		)
	$debug/Container/log_out.pressed.connect(func():
		NET.get_node("net_game").disconnect_game()
		NET.get_node("net_voice").disconnect_voice()
		)
	$debug/Container/delete_world.pressed.connect(func():
		if has_node("World"):
			$World.queue_free()
		)
	$debug/Container/zan_test.toggled.connect(func(mod):
		if mod:
			zanaves(2)
		else:
			zanaves(1)
		)

func buttons():
	Nlist[0].text_changed.connect(func(text):
		CLIENT.log_in_data["USERNAME"] = str(text)
		)
	Nlist[1].text_changed.connect(func(text):
		CLIENT.log_in_data["PASSWORD"] = str(text)
		)
	Nlist[2].pressed.connect(func():
		if CLIENT.log_in_data["USERNAME"].length() < 3:
			Nlist[3].text = "Слишком короткое имя"
			return
		elif CLIENT.log_in_data["USERNAME"].length() > 14:
			Nlist[3].text = "Слишком длинное имя"
			return
		elif CLIENT.log_in_data["PASSWORD"].length() == 0:
			Nlist[3].text = "Хотяб один символ пароля"
			return
		elif Nlist[10].time_left != 0:
			Nlist[3].text = "Не спамьте вход"
			return
		else:
			Nlist[10].start()
			Nlist[3].text = "Ожидаем ответ"
			Nlist[0].editable = false
			Nlist[1].editable = false
			var data = ["client_log_in", CLIENT.log_in_data]
			send_ms(data)
		)
	Nlist[9].pressed.connect(func():
		get_tree().quit()
		)
	
	for b in Nlist[5].button_group.get_buttons():
		b.toggled.connect(func(mod):
			if Nlist[5].button_group.get_pressed_button() == null:
				await zanaves(1)
				$UI/mainbox/mainbox2/Window.visible = $UI/mainbox/mainbox2/Window.get_meta("PV")
			else:
				await zanaves(2)
				$UI/mainbox/mainbox2/Window.visible = $UI/mainbox/mainbox2/Window.get_meta("PV")
			)
	
	Nlist[5].button_group.pressed.connect(func(buttons):
		for n in $UI/mainbox/mainbox2/Window/Panel/Panel.get_children():
			if n.name != buttons.name:
				n.visible = false
		match buttons.name:
			"lobby_list":
				Nlist[11].visible = true
			"profile" :
				Nlist[12].visible = true
			"settings" :
				Nlist[13].visible = true
			"autors" :
				Nlist[14].visible = true
			"rules" :
				Nlist[15].visible = true
		)

func set_king_material():
	king_material["M_BEAR"].albedo_color = CLIENT.logpass.SETTINGS["COLOR_DED"]["mBear"]
	king_material["M_BULL"].albedo_color = CLIENT.logpass.SETTINGS["COLOR_DED"]["mBull"]
	king_material["M_DRAGON"].albedo_color = CLIENT.logpass.SETTINGS["COLOR_DED"]["mDragon"]
	king_material["M_EAGLE"].albedo_color = CLIENT.logpass.SETTINGS["COLOR_DED"]["mEagle"]
	king_material["M_ELEPHANT"].albedo_color = CLIENT.logpass.SETTINGS["COLOR_DED"]["mElephant"]
	king_material["M_LION"].albedo_color = CLIENT.logpass.SETTINGS["COLOR_DED"]["mLion"]

func _ded_mode_set_color(color, king):
	match king:
		"Bear" : king_material["M_BEAR"].albedo_color = color
		"Bull" : king_material["M_BULL"].albedo_color = color
		"Dragon" : king_material["M_DRAGON"].albedo_color = color
		"Eagle" : king_material["M_EAGLE"].albedo_color = color
		"Elephant" : king_material["M_ELEPHANT"].albedo_color = color
		"Lion" : king_material["M_LION"].albedo_color = color
		_ : pass

func _ded_mode_set_ok():
	CLIENT.logpass.SETTINGS["COLOR_DED"]["mBear"] = Color(king_material["M_BEAR"].albedo_color)
	CLIENT.logpass.SETTINGS["COLOR_DED"]["mBull"] = Color(king_material["M_BULL"].albedo_color)
	CLIENT.logpass.SETTINGS["COLOR_DED"]["mDragon"] = Color(king_material["M_DRAGON"].albedo_color)
	CLIENT.logpass.SETTINGS["COLOR_DED"]["mEagle"] = Color(king_material["M_EAGLE"].albedo_color)
	CLIENT.logpass.SETTINGS["COLOR_DED"]["mElephant"] = Color(king_material["M_ELEPHANT"].albedo_color)
	CLIENT.logpass.SETTINGS["COLOR_DED"]["mLion"] = Color(king_material["M_LION"].albedo_color)
	CLIENT._save_client_local_logpass()

func client_log_in(data):
	Nlist[3].text = data[1]
	if data[1] == "OK":
		for i in Nlist.size():
			if i < 4 and "visible" in Nlist[i]:
				Nlist[i].visible = false
			elif i > 3 and "visible" in Nlist[i]:
				Nlist[i].visible = true
	else:
		Nlist[0].editable = true
		Nlist[1].editable = true


func zanaves(n):
	if n == 2:
		$UI/mainbox/mainbox2/Window.set_meta("PV", true)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property($Zanaves/SubViewport/World_dop/zanaves/karniz2, "position", Vector3(4.36, 3.71, 2.1), 1.5)
		await tween.finished
	elif n == 1:
		$UI/mainbox/mainbox2/Window.set_meta("PV", false)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property($Zanaves/SubViewport/World_dop/zanaves/karniz2, "position", Vector3(4.36, 3.71, 5.36), 2)
	else:
		$UI/mainbox/mainbox2/Window.set_meta("PV", false)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property($Zanaves/SubViewport/World_dop/zanaves/karniz2, "position", Vector3(4.36, 3.71, 8.46), 1.5)
	










#
