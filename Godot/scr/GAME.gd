extends Node
@export var cam_settings := [0, 15, 0.15, null, null]
var maxWind := 0.2
var wind := maxWind

var lobby_parametrs := {}
@export var players_user := {}
@export var active_user := []
var list_you_figur := []

@onready var TABLE: Node3D = $WORLD/TABLE

@export var figura_parametr: Dictionary[String, Array] = {
	"help" : ["speed", "attack", "price", "win_ball", "need_upgrade"],
	"king" : [1, 0, 30, 90, ""],
	"peshk" : [2, 0, 12, 12, ""],
	"peshk_fan" : [2, 0, 12, 24, "peshk"],
	"kon" : [3, 1, 18, 30, "peshk"],
	"kon_fan" : [3, 1, 18, 48, "kon"],
	"slon" : [2, 0, 24, 36, "peshk"],
	"slon_fan" : [2, 0, 24, 60, "slon"],
	"lada" : [1, 2, 30, 60, "kon"],
	"lada_fan" : [1, 2, 30, 90, "lada"],
	"lada_fan_ready" : [1, 2, 36, 90, "lada_fan"],
	}

const figura := {
	"flag_bear" : preload("res://lvl/game/flags/flag_bear.tscn"),
	"flag_bull" : preload("res://lvl/game/flags/flag_bull.tscn"),
	"flag_dragon" : preload("res://lvl/game/flags/flag_dragon.tscn"),
	"flag_eagle" : preload("res://lvl/game/flags/flag_eagle.tscn"),
	"flag_elephant" : preload("res://lvl/game/flags/flag_elephant.tscn"),
	"flag_lion" : preload("res://lvl/game/flags/flag_lion.tscn"),
	"flag_rat" : preload("res://lvl/game/flags/flag_rat.tscn"),
	
	"gex_eagle" : preload("res://mesh/gex_cube.res"),
	"gex_elephant" : preload("res://mesh/gex_krug.res"),
	"gex_dragon" : preload("res://mesh/gex_minus.res"),
	"gex_lion" : preload("res://mesh/gex_plus.res"),
	"gex_bear" : preload("res://mesh/gex_star.res"),
	"gex_bull" : preload("res://mesh/gex_trio.res"),
	
	"king" : preload("res://mesh_figura/king.tscn"),
	"peshk" : preload("res://mesh_figura/peshk.tscn"),
	"peshk_fan" : preload("res://mesh_figura/peshk_fan.tscn"),
	"kon" : preload("res://mesh_figura/kon.tscn"),
	"kon_fan" : preload("res://mesh_figura/kon_fan.tscn"),
	"slon" : preload("res://mesh_figura/slon.tscn"),
	"slon_fan" : preload("res://mesh_figura/slon_fan.tscn"),
	"lada" : preload("res://mesh_figura/lada.tscn"),
	"lada_fan" : preload("res://mesh_figura/lada_fan.tscn"),
	"lada_fan_ready" : preload("res://mesh_figura/lada_fan_ready.tscn"),
	}

const material := {
	"walk_m" : preload("res://visual/material/game/walk.tres"),
	"attack_m" : preload("res://visual/material/game/attack.tres"),
	"buy_bad_m" : preload("res://visual/material/figura/buy_bad.tres"),
	"buy_good_m" : preload("res://visual/material/figura/buy_good.tres"),
	"M_BEAR" : preload("res://visual/material/king/mBear.tres"),
	"M_BULL" : preload("res://visual/material/king/mBull.tres"),
	"M_DRAGON" : preload("res://visual/material/king/mDragon.tres"),
	"M_EAGLE" : preload("res://visual/material/king/mEagle.tres"),
	"M_ELEPHANT" : preload("res://visual/material/king/mElephant.tres"),
	"M_LION" : preload("res://visual/material/king/mLion.tres"),
	}

const object := {
	"cute_cube" : preload("res://mesh_figura/cute_cube.tscn"),
	"fon_flat_1" : preload("res://visual/material/market/fon_flat.tres"),
	"fon_flat_2" : preload("res://visual/material/market/fon_flat_2.tres"),
	"walk_check" : preload("res://mesh_figura/walk_check.tscn"),
	"pipe_go" : preload("res://lvl/game/pipe_go.tscn"),
	"pipe_attack" : preload("res://lvl/game/pipe_attack.tscn"),
	}

const king_gerb := [
	null, 
	null, 
	preload("res://king/gerb/Bear.png"), 
	preload("res://king/gerb/Bull.png"), 
	preload("res://king/gerb/Dragon.png"), 
	preload("res://king/gerb/Eagle.png"), 
	preload("res://king/gerb/Elephant.png"), 
	preload("res://king/gerb/Lion.png")
	]

const kazna_ico := [
	preload("res://koloda/kazna/K_00.png"), 
	preload("res://koloda/kazna/K_00_Op.png"), 
	preload("res://koloda/kazna/K_1.png"), 
	preload("res://koloda/kazna/K_1_Op.png"), 
	preload("res://koloda/kazna/K_2.png"), 
	preload("res://koloda/kazna/K_2_Op.png"), 
	preload("res://koloda/kazna/K_3.png"), 
	preload("res://koloda/kazna/K_3_Op.png"), 
	preload("res://koloda/kazna/K_4.png"), 
	preload("res://koloda/kazna/K_4_Op.png")
	]

var kazna_ico_select := 0

@export var flag: Dictionary[String, bool] = {
	"hard_work" : false,
	"gex_check" : false,
	"first_turn" : false,
	"you_turn" : false,
	"king_alive" : false,
	"go" : false,
	"buy" : false,
	"rotate" : false,
	"rat_alive" : false,
	"buy_ok" : false,
	"chat_focus" : false,
	"chat_mouse" : false,
	"server_check" : false,
	}

const action_flag := ["hard_work", "go", "buy", "rotate", "chat_focus"]

var walk: Dictionary[String, Array] ={
	"go" : [],
	"attack" : []
	}

var first_turn_name
var action := false
var menu_open := false
@export var have_tusk := 0

@onready var gex := {
	"forward" : null,
	"select" : null,
	"buy_ghost" : null,
	"effect_holder" : $WORLD/gex_effect_holder,
	"effect_select" : $WORLD/gex_effect_holder/gex_effect,
	"effect_rotate" : $WORLD/gex_effect_holder/rotate_system_v2
	}




func _ready() -> void:
	if R.status == "CLIENT":
		lobby_parametrs = C.lobby_scene.lobby_parametrs.duplicate()
		players_user = C.lobby_scene.players_user.duplicate()
		UI_connect()
	elif R.status == "SERVER_GAME":
		lobby_parametrs = SG.lobby_parametrs.duplicate()
		players_user = SG.players_user.duplicate()
		flag["server_check"] = true
		randomize()
	
	for lvl in ["A", "B"]:
		if TABLE.has_node(lvl):
			for g in TABLE.get_node(lvl).get_children():
				if g.name.begins_with("GEX"):
					g.add_to_group("baff_"+lvl)


func _process(delta: float) -> void:
	if R.status != "CLIENT":
		return
	
	if C.lobby_scene.visible == false and !flag["chat_focus"]:
		$USER/cam_piv_1/cam_piv_2.rotation_degrees.x += (cam_settings[0] - $USER/cam_piv_1/cam_piv_2.rotation_degrees.x)/12
		if Input.is_action_pressed("A"):
			$USER/cam_piv_1.rotation_degrees.y -= 0.55
		elif Input.is_action_pressed("D"):
			$USER/cam_piv_1.rotation_degrees.y += 0.55
	
	for f in action_flag:
		if flag[f]:
			action = true
			break
		else:
			action = false
	
	#if have_tusk == 0:
		#flag["you_turn"] = false


#region input
func _input(event):
	if R.status != "CLIENT" or menu_open or flag["hard_work"]:
		return
	
	if flag["chat_focus"]:
		if !event.is_action_pressed("esc") or !event.is_action_pressed("LMB"):
			return
		else:
			if flag["chat_mouse"]:
				return
			_chat_focus_cansel()
			return
	
	if event is InputEventKey:
		_input_key(event)
	elif event is InputEventMouseButton:
		_input_mouse(event)


func _input_key(event):
	if event.is_action_pressed("W"):
		cam_settings[0] = -40
		_cam_down()
	if event.is_action_released("W"):
		cam_settings[0] = 0
		_cam_up()
	if event.is_action("esc") and action:
		action_cansel()

func _input_mouse(event):
	Audio._on_ui_click()
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_tween_rotate($USER/cam_piv_1.rotation_degrees.y + cam_settings[1])
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_tween_rotate($USER/cam_piv_1.rotation_degrees.y - cam_settings[1])
	elif event.is_action_pressed("RMB"):
		cam_settings[0] = -40
		_cam_down()
	elif event.is_action_released("RMB"):
		cam_settings[0] = 0
		_cam_up()
	elif event.is_action_pressed("LMB"):
		if flag["chat_focus"]:
			return
		#elif flag["go"]:
			
		#elif flag["buy"]:


func _tween_rotate(target: float):
	if cam_settings[3]:
		cam_settings[3].kill()
	cam_settings[3] = create_tween()
	cam_settings[3].tween_property($USER/cam_piv_1, "rotation_degrees:y", target, cam_settings[2]).set_trans(Tween.TRANS_LINEAR)

func _cam_down():
	if cam_settings[4]:
		cam_settings[4].kill()
	cam_settings[4] = create_tween()
	cam_settings[4].tween_property($USER/cam_piv_1, "global_position:y", -0.3, 0.3)

func _cam_up():
	if cam_settings[4]:
		cam_settings[4].kill()
	cam_settings[4] = create_tween()
	cam_settings[4].tween_property($USER/cam_piv_1, "global_position:y", 0.0, 0.3)

func _chat_focus_cansel():
	$USER/UI/CHAT/VB/panel/Box/LineEdit.release_focus()



#endregion

#region rpc
@rpc("authority", "call_local", "reliable")
func spawn_start():
	if R.status == "CLIENT":
		for u in players_user:
			if players_user[u]["username"] == C.USERNAME:
				match players_user[u]["spawn"]:
					"2" : $USER/cam_piv_1.rotation_degrees.y = 180
					"3" : $USER/cam_piv_1.rotation_degrees.y = 120
					"4" : $USER/cam_piv_1.rotation_degrees.y = 60
					"5" : $USER/cam_piv_1.rotation_degrees.y = 0
					"6" : $USER/cam_piv_1.rotation_degrees.y = 300
					"7" : $USER/cam_piv_1.rotation_degrees.y = 240
					_ : $USER/cam_piv_1.rotation_degrees.y = 0
	
	for u in players_user:
		var spawn = players_user[u]["spawn"]
		var player_king = players_user[u]["king"]
		
		if !player_king in ["2", "3", "4", "5", "6", "7"]:
			player_king = ""
		
		match spawn:
			"2" : spawn = "A"
			"3" : spawn = "B"
			"4" : spawn = "C"
			"5" : spawn = "D"
			"6" : spawn = "E"
			"7" : spawn = "F"
			_ : spawn = ""
		
		if spawn == "":
			continue
		if player_king == "":
			continue
		
		active_user.append(u)
		monolit(u)
		
		var gex = "D_"+spawn
		await figura_spawn(players_user[u], "king", TABLE.get_node(gex+"/GEX").get_path())
		for n in range(2, 7):
			await figura_spawn(players_user[u], "peshk", TABLE.get_node(gex+"/GEX"+str(n)).get_path())
	
	if R.status == "SERVER_GAME":
		$WORLD/CloudSpawn.queue_free()
		$USER/UI/CHAT/VB/panel/Box/chat.append_text("\n SERVER_GAME")
		await get_tree().create_timer(1).timeout
		rpc("update_power")
		await get_tree().create_timer(1).timeout
		pick_first_turn()

@rpc("authority", "call_local", "reliable")
func figura_spawn(player, fig_name, gex_path):
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	if R.status == "CLIENT" and player["username"] == C.USERNAME:
		list_you_figur.append(fig_name)
		if fig_name == "king":
			flag["king_alive"] = true
	
	var gex = get_node(gex_path)
	var player_gex
	match player["king"]:
		"2" : player_gex = "bear"
		"3" : player_gex = "bull"
		"4" : player_gex = "dragon"
		"5" : player_gex = "eagle"
		"6" : player_gex = "elephant"
		"7" : player_gex = "lion"
		"rat" : player_gex = "rat"
		_ : return
	
	var instance = figura[fig_name].instantiate()
	var instance2 = MeshInstance3D.new()
	instance2.mesh = figura["gex_"+player_gex]
	instance2.name = "pad"
	
	gex.add_child(instance)
	
	if fig_name == "king":
		await get_tree().process_frame
		var instance3 = figura["flag_"+player_gex].instantiate()
		gex.get_node("king").add_child(instance3)
		for f in figura_parametr.keys():
			if gex.is_in_group(f) and f != "king":
				gex.get_node(f).queue_free()
				gex.remove_from_group(f)
	else:
		if gex.is_in_group(figura_parametr[fig_name][4]):
			gex.get_node(figura_parametr[fig_name][4]).queue_free()
			gex.remove_from_group(figura_parametr[fig_name][4])
	
	if !gex.has_node("pad"):
		gex.add_child(instance2)
	
	gex.add_to_group(player["username"])
	gex.add_to_group(fig_name)
	flag["hard_work"] = false

@rpc("any_peer", "call_local", "reliable")
func send_chat(text):
	$USER/UI/CHAT/VB/panel/Box/chat.append_text(text)

@rpc("authority", "call_local", "reliable")
func send_turn(active_user, first_turn):
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	
	if R.status == "SERVER_GAME":
		var text = "\n"+"[color=green]"+"ХОД ИГРОКА: "+str(players_user[first_turn_name]["username"])+"[/color]"
		rpc("send_chat", text)
	if R.status == "CLIENT":
		flag["first_turn"] = first_turn
		if flag["first_turn"]:
			Audio.Action2_sound_play("first_turn")
		else:
			Audio.Action2_sound_play("turn")
		if str(C.USERNAME) == str(players_user[active_user[0]]["username"]):
			flag["you_turn"] = true
			$USER/UI/Turn_W.popup()
			have_tusk = 2
			$USER/UI/player_turn_go.text = "ЗАВЕРШИТЬ ХОД"
		else:
			flag["you_turn"] = false
			have_tusk = 0
			$USER/UI/player_turn_go.text = str(players_user[active_user[0]]["username"])+" - ходи уже"
	
	flag["hard_work"] = false

@rpc("any_peer", "call_local", "reliable")
func S_go(gex_signal_path, gex_select_path, player):
	var sender = multiplayer.get_remote_sender_id()
	var gex_signal = get_node(gex_signal_path)
	var gex_select = get_node(gex_select_path)
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	
	if !flag["server_check"]:
		for pu in players_user.keys():
			if players_user[pu]["username"] == players_user[player]["username"]:
				player = pu
		for f in figura_parametr.keys():
			if gex_select.is_in_group(f):
				gex_select.get_node(f).reparent(gex_signal, false)
				gex_select.get_node("pad").reparent(gex_signal, false)
				gex_select.remove_from_group(f)
				gex_select.remove_from_group(players_user[player]["username"])
				gex_signal.add_to_group(f)
				gex_signal.add_to_group(players_user[player]["username"])
				rpc("update_power")
	
	else:
		for f in figura_parametr.keys():
			if gex_select.is_in_group(f):
				var area = gex_select.get_node(f).get_node("walk").get_overlapping_areas()
				for a in area:
					if gex_signal == a:
						flag["server_check"] = false
						flag["hard_work"] = false
						rpc("S_go", gex_signal_path, gex_select_path, sender)
						var text = "\n"+"[color=green]"+"Игрок: "+players_user[sender]["username"]+" сдвинул фигуру"+"[/color]"
						rpc("send_chat", text)
						rpc("update_power")
	if R.status == "SERVER_GAME":
		flag["server_check"] = true
	flag["hard_work"] = false

@rpc("any_peer", "call_local", "reliable")
func S_attack(gex_signal_path, gex_select_path, player):
	var sender = multiplayer.get_remote_sender_id()
	var gex_signal = get_node(gex_signal_path)
	var gex_select = get_node(gex_select_path)
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	
	if !flag["server_check"]:
		for pu in players_user.keys():
			if players_user[pu]["username"] == players_user[player]["username"]:
				player = pu
		for f in figura_parametr.keys():
			if gex_select.is_in_group(f):
				pass
				
				#gex_select.get_node(f).reparent(gex_signal, false)
				#gex_select.get_node("pad").reparent(gex_signal, false)
				#gex_select.remove_from_group(f)
				#gex_select.remove_from_group(players_user[player]["username"])
				#gex_signal.add_to_group(f)
				#gex_signal.add_to_group(players_user[player]["username"])
	
	else:
		for f in figura_parametr.keys():
			if gex_select.is_in_group(f):
				var area = gex_select.get_node(f).get_node("attack").get_overlapping_areas()
				for a in area:
					if gex_signal == a:
						flag["server_check"] = false
						flag["hard_work"] = false
						rpc("S_attack", gex_signal_path, gex_select_path, sender)
						for pu in players_user.keys():
							if gex_select.is_in_group(players_user[pu]["username"]):
								var oponent = players_user[pu]["username"]
								var text = "\n"+"[color=green]"+"Игрок: "+players_user[sender]["username"]+" атаковал фигуру игрока: "+oponent+"[/color]"
								rpc("send_chat", text)
								break
						rpc("update_power")
	if R.status == "SERVER_GAME":
		flag["server_check"] = true
	flag["hard_work"] = false

@rpc("any_peer", "call_local", "reliable")
func S_buy(gex_signal_path, meta, player):
	var sender = multiplayer.get_remote_sender_id()
	var gex_signal = get_node(gex_signal_path)
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	
	if !flag["server_check"]:
		for pu in players_user.keys():
			if players_user[pu]["username"] == players_user[player]["username"]:
				player = pu
		players_user[player]["kazna"] -= figura_parametr[meta][2]
		rpc("figura_spawn", players_user[player], meta, gex_signal_path)
		rpc("kazna_update", players_user)
		rpc("update_power")
	
	else:
		if players_user[sender]["kazna"] >= figura_parametr[meta][2]:
			if gex_signal_path.is_in_group(players_user[sender]["username"]) or gex_signal_path.is_in_group(players_user[sender]["username"]+"_power"):
				flag["server_check"] = false
				flag["hard_work"] = false
				rpc("S_buy", gex_signal_path, meta, sender)
				var text = "\n"+"[color=green]"+"Игрок: "+players_user[sender]["username"]+" купил фигуру"+"[/color]"
				rpc("send_chat", text)
				rpc("update_power")
	if R.status == "SERVER_GAME":
		flag["server_check"] = true
	flag["hard_work"] = false

@rpc("authority", "call_local", "reliable")
func kazna_update(pu):
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	if multiplayer.is_server():
		return
	
	Audio.Action_sound_play("kazna")
	for pu2 in pu.keys():
		var kazna_ico_select_2 := 0
		players_user[pu2]["kazna"] = pu[pu2]["kazna"]
		if players_user[pu2]["kazna"] == 0:
			kazna_ico_select_2 = 0
		elif players_user[pu2]["kazna"] > 0 and players_user[pu2]["kazna"] < 12:
			kazna_ico_select_2 = 2
		elif players_user[pu2]["kazna"] >= 12 and players_user[pu2]["kazna"] < 24:
			kazna_ico_select_2 = 4
		elif players_user[pu2]["kazna"] >= 24 and players_user[pu2]["kazna"] < 36:
			kazna_ico_select_2 = 6
		elif players_user[pu2]["kazna"] > 36:
			kazna_ico_select_2 = 8
		else:
			kazna_ico_select_2 = 0
		
		if players_user[pu2]["username"] == C.USERNAME:
			kazna_ico_select = kazna_ico_select_2
			$USER/UI/Kazna_b/Count_l.text =  str(players_user[pu2]["kazna"])
			$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
		else:
			$WORLD/monolit_players.get_node("monolit_"+players_user[pu2]["spawn"]).get_node("info/kazna").texture = kazna_ico[kazna_ico_select_2]

@rpc("authority", "call_local", "reliable")
func update_power():
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	for pu in players_user.keys():
		players_user[pu]["kazna_power"] = 0
	
	var allgex = TABLE.find_children("GEX*", "", true, false)
	for gedel in allgex:
		var cube_del = gedel.find_children("cute_cube", "", true, false)
		if cube_del.size() > 0:
			for cube_del2 in cube_del:
				cube_del2.free()
		for gpdel in gedel.get_groups():
			if gpdel.ends_with("_power"):
				gedel.remove_from_group(gpdel)
	
	await get_tree().process_frame
	await get_tree().physics_frame
	
	for ge in allgex:
		for u in players_user.keys():
			if ge.is_in_group(players_user[u]["username"]):
				for f in figura_parametr.keys():
					if ge.is_in_group(f):
						for gpl in ge.get_node(f).get_node("attack").get_overlapping_areas():
							gpl.add_to_group(players_user[u]["username"]+"_power")
						continue
	
	await get_tree().process_frame
	await get_tree().physics_frame
	
	for ge2 in allgex:
		var power_groups = []
		for gp in ge2.get_groups():
			if gp.ends_with("_power"):
				power_groups.append(gp)
		if power_groups.size() == 1:
			var username = power_groups[0].split("_power")[0]
			for u in players_user.keys():
				if players_user[u]["username"] == username:
					var cute_cube = object["cute_cube"].instantiate()
					cute_cube.name = "cute_cube"
					if !multiplayer.is_server():
						var material_cube
						match players_user[u]["king"]:
							"2" : material_cube = material["M_BEAR"]
							"3" : material_cube = material["M_BULL"]
							"4" : material_cube = material["M_DRAGON"]
							"5" : material_cube = material["M_EAGLE"]
							"6" : material_cube = material["M_ELEPHANT"]
							"7" : material_cube = material["M_LION"]
							_ : return
						cute_cube.get_node("cube").set_surface_override_material(0, material_cube)
					if !ge2.has_node("cute_cube") and !ge2.has_node("pad"):
						ge2.add_child(cute_cube)
						players_user[u]["kazna_power"] += 1
					continue
	
	flag["hard_work"] = false

@rpc("any_peer", "call_local", "reliable")
func turn_update(info, info2):
	if flag["hard_work"]:
		while flag["hard_work"]:
			await get_tree().process_frame
	flag["hard_work"] = true
	if info == "turn_final":
		if flag["first_turn"]:
			flag["first_turn"] = false
			
			var spawns := {}
			for ap2 in active_user:
				spawns[ap2] = int(players_user[ap2]["spawn"])
			var sorted_ap = active_user.duplicate()
			sorted_ap.sort_custom(func(a, b): return spawns[a] < spawns[b])
			var first_player_index = sorted_ap.find(active_user[0])
			var len_s = sorted_ap.size()
			active_user.clear()
			if info2:
				for i in range(len_s):
					active_user.append(sorted_ap[(first_player_index+i) % len_s])
			else:
				for i in range(len_s):
					active_user.append(sorted_ap[(first_player_index-i+len_s) % len_s])
			rpc("send_turn", active_user, flag["first_turn"])
		else:
			var turn_name = active_user[0]
			active_user.erase(turn_name)
			active_user.append(turn_name)
			rpc("send_turn", active_user, flag["first_turn"])
	
	flag["hard_work"] = false


#endregion

#region UI
func monolit(u):
	var king = int(players_user[u]["king"])
	match players_user[u]["spawn"]:
		"2" : 
			$WORLD/monolit_players/monolit_2.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_2.get_node("info").visible = true
			$WORLD/monolit_players/monolit_2.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"3" : 
			$WORLD/monolit_players/monolit_3.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_3.get_node("info").visible = true
			$WORLD/monolit_players/monolit_3.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"4" : 
			$WORLD/monolit_players/monolit_4.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_4.get_node("info").visible = true
			$WORLD/monolit_players/monolit_4.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"5" : 
			$WORLD/monolit_players/monolit_5.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_5.get_node("info").visible = true
			$WORLD/monolit_players/monolit_5.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"6" : 
			$WORLD/monolit_players/monolit_6.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_6.get_node("info").visible = true
			$WORLD/monolit_players/monolit_6.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"7" : 
			$WORLD/monolit_players/monolit_7.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_7.get_node("info").visible = true
			$WORLD/monolit_players/monolit_7.get_node("info").get_node("username_label").text = str(players_user[u]["username"])

func ava_update(ava_name):
	if R.status != "CLIENT":
		return
	
	var avatar = AccData.avatar_from_base64(C.avatar_user[ava_name])
	if avatar == null:
		avatar = preload("res://import/ava_placehold.png")
	for u in players_user:
		if ava_name == players_user[u]["username"]:
			match players_user[u]["spawn"]:
				"2" : $WORLD/monolit_players/monolit_2.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"3" : $WORLD/monolit_players/monolit_3.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"4" : $WORLD/monolit_players/monolit_4.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"5" : $WORLD/monolit_players/monolit_5.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"6" : $WORLD/monolit_players/monolit_6.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"7" : $WORLD/monolit_players/monolit_7.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar

func UI_connect():
	chat_connect()
	turn_button()
	kazna()





func chat_connect():
	$USER/UI/CHAT/VB/panel/Box/LineEdit.text_submitted.connect(chat)
	$USER/UI/CHAT/VB/panel/Box/LineEdit.focus_entered.connect(func(): flag["chat_focus"] = true)
	$USER/UI/CHAT/VB/panel/Box/LineEdit.focus_exited.connect(func(): flag["chat_focus"] = false)
	$USER/UI/CHAT/VB/panel/Box/LineEdit.mouse_entered.connect(func(): flag["chat_mouse"] = true)
	$USER/UI/CHAT/VB/panel/Box/LineEdit.mouse_exited.connect(func(): flag["chat_mouse"] = false)
	$USER/UI/CHAT/VB/HButton/Plus_chat.pressed.connect(func(): $USER/UI/CHAT.size += Vector2(25, 25))
	$USER/UI/CHAT/VB/HButton/Minus_chat.pressed.connect(func(): $USER/UI/CHAT.size -= Vector2(25, 25))

func chat(text):
	$USER/UI/CHAT/VB/panel/Box/LineEdit.clear()
	var messege = "\n"+"[color=#c9001e]"+str(C.USERNAME)+"[/color]: "+str(text)
	rpc("send_chat", messege)

func turn_button():
	$USER/UI/player_turn_go.pressed.connect(func(): 
		if flag["you_turn"]:
			if flag["first_turn"]:
				var you_sosed_A
				var you_sosed_B
				var you_spawn
				for au in active_user:
					if players_user[au]["username"] == C.USERNAME:
						you_spawn = int(players_user[au]["spawn"])
						match you_spawn:
							2: 
								you_sosed_A = 7
								you_sosed_B = you_spawn + 1
							7: 
								you_sosed_A = you_spawn - 1
								you_sosed_B = 2
							_:
								you_sosed_A = you_spawn - 1
								you_sosed_B = you_spawn + 1
				for au2 in active_user:
					if int(players_user[au2]["spawn"]) == you_sosed_A:
						$USER/UI/Turn_W_2/Box/Margin/Box/A_player.text = players_user[au2]["username"]
					if int(players_user[au2]["spawn"]) == you_sosed_B:
						$USER/UI/Turn_W_2/Box/Margin/Box/B_player.text = players_user[au2]["username"]
				$USER/UI/Turn_W_2.popup()
				return
			rpc_id(1, "turn_update", "turn_final", "")
		else:
			rpc_id(1, "turn_update", "turn_zaebal", "")
		)
	
	$USER/UI/Turn_W_2/Box/Margin/Box/A_player.pressed.connect(func():
		rpc_id(1, "turn_update", "turn_final", false)
		$USER/UI/Turn_W_2.hide()
		)
	$USER/UI/Turn_W_2/Box/Margin/Box/B_player.pressed.connect(func():
		rpc_id(1, "turn_update", "turn_final", true)
		$USER/UI/Turn_W_2.hide()
		)


func kazna():
	$USER/UI/Kazna_b.pressed.connect(kazna_nx.bind("open"))
	$USER/UI/Kazna_b.mouse_entered.connect(kazna_nx.bind("entered"))
	$USER/UI/Kazna_b.mouse_exited.connect(kazna_nx.bind("exited"))
	$USER/UI/Info_W.close_requested.connect(close_window.bind("info"))
	$USER/UI/Kazna_W.close_requested.connect(close_window.bind("kazna"))
	$USER/UI/Info_W.focus_exited.connect(close_window.bind("info"))
	$USER/UI/Kazna_W.focus_exited.connect(close_window.bind("kazna"))
	await get_tree().create_timer(1.0).timeout
	for option in $USER/UI/Kazna_W/Magaz/VBox/Options.get_children():
		option.get_node("Adept/Fon").add_theme_stylebox_override("panel", preload("res://visual/material/market/fon_flat.tres"))
		option.get_node("Fanat/Fon").add_theme_stylebox_override("panel", preload("res://visual/material/market/fon_flat.tres"))
		
		option.get_node("Adept/Button").pressed.connect(buy.bind(option.name))
		option.get_node("Fanat/Button").pressed.connect(buy.bind(option.name+"_fan"))
		option.get_node("Adept/Button").mouse_entered.connect(func(): option.get_node("Adept/Fon").add_theme_stylebox_override("panel", object["fon_flat_1"]))
		option.get_node("Fanat/Button").mouse_entered.connect(func(): option.get_node("Fanat/Fon").add_theme_stylebox_override("panel", object["fon_flat_1"]))
		option.get_node("Adept/Button").mouse_exited.connect(func(): option.get_node("Adept/Fon").add_theme_stylebox_override("panel", object["fon_flat_2"]))
		option.get_node("Fanat/Button").mouse_exited.connect(func(): option.get_node("Fanat/Fon").add_theme_stylebox_override("panel", object["fon_flat_2"]))
	$USER/UI/Kazna_W/Magaz/VBox/Info/Info_button.pressed.connect(func(): $USER/UI/Info_W.popup())

func kazna_nx(nx):
	if nx == "entered":
		kazna_ico_select += 1
		$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	elif nx == "exited":
		kazna_ico_select -= 1
		$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	elif nx == "open":
		action_cansel()
		$USER/UI/Kazna_W.popup()

func close_window(window):
	match window:
		"info" : $USER/UI/Info_W.hide()
		"kazna" : $USER/UI/Kazna_W.hide()






#endregion

#region gex_func
func gex_entered(gex_signal):
	if flag["hard_work"] or flag["chat_focus"]:
		return
	if gex_signal.is_in_group(C.USERNAME):
		gex_signal.position.y = 0.05
	buy_gex(gex_signal, "entered")

func gex_exited(gex_signal):
	#if flag["hard_work"] or flag["chat_focus"]:
		#return
	if gex_signal != gex["select"]:
		gex_signal.position.y = 0.0
	buy_gex(gex_signal, "exited")

func gex_pressed(gex_signal):
	if flag["gex_check"]:
		print(gex_signal, " Группы: ", str(gex_signal.get_groups()))
	if flag["hard_work"] or flag["chat_focus"] or !flag["you_turn"]:
		return
	
	if gex["select"]:
		gex["select"].position.y = 0.0
	
	gex["effect_select"].global_position = gex_signal.global_position
	
	if flag["go"]:
		if gex_signal.get_node_or_null("pipe_go") and have_tusk:
			if flag["king_alive"]:
				have_tusk -= 1
			else:
				have_tusk -= 2
			rpc_id(1, "S_go", gex_signal.get_path(), gex["select"].get_path(), C.USERNAME)
			action_cansel()
		if gex_signal.get_node_or_null("pipe_attack") and have_tusk == 2:
			rpc_id(1, "S_attack", gex_signal.get_path(), gex["select"].get_path(), C.USERNAME)
			action_cansel()
	
	elif flag["buy"]:
		if flag["buy_ok"] and have_tusk:
			if flag["king_alive"]:
				have_tusk -= 1
			else:
				have_tusk -= 2
			rpc_id(1, "S_buy", gex_signal.get_path(), gex["buy_ghost"].get_meta("fig_buy_name"), C.USERNAME)
			action_cansel()
	
	else:
		if gex_signal.is_in_group(C.USERNAME) and gex_signal != gex["select"]:
			gex["select"] = gex_signal
			go()

func buy_gex(gex_signal, enorex):
	if !flag["buy"] or gex["buy_ghost"] == null:
		return
	
	flag["hard_work"] = true
	
	if enorex == "exited":
		for fnk in figura_parametr.keys():
			if gex_signal.is_in_group(fnk):
				gex_signal.get_node(fnk).visible = true
		return
	
	var meta_name = gex["buy_ghost"].get_meta("fig_buy_name")
	flag["buy_ok"] = true
	
	gex["buy_ghost"].global_position = gex_signal.global_position
	if meta_name == "peshk" :
		if gex_signal.is_in_group(C.USERNAME+"_power"):
			for g in gex_signal.get_groups():
				if g.ends_with("_power") and g != str(C.USERNAME+"_power"):
					flag["buy_ok"] = false
					break
				if g in figura_parametr:
					flag["buy_ok"] = false
					break
	else:
		if !(gex_signal.is_in_group(figura_parametr[meta_name][4]) and gex_signal.is_in_group(C.USERNAME)):
			flag["buy_ok"] = false
	
	if flag["buy_ok"]:
		gex["buy_ghost"].get_node("mesh").material_override = material["buy_good_m"]
	else:
		gex["buy_ghost"].get_node("mesh").material_override = material["buy_bad_m"]
	
	for fnk in figura_parametr.keys():
		if gex_signal.is_in_group(fnk):
			gex_signal.get_node(fnk).visible = false
	
	flag["hard_work"] = false
#endregion

#region turn
func go():
	if flag["hard_work"]:
		return
	flag["hard_work"] = true
	flag["go"] = true
	for w in walk.keys():
		walk[w] = []
	
	var lvl_start = check_lvl(gex["select"].get_parent().get_name())
	var speed: int = check_speed()
	var ring := 0
	var walk_go_copy := []
	var walk_check = object["walk_check"].instantiate()
	walk_check.name = "walk_check"
	
	while speed > 0 :
		var check_walk_area
		
		if ring == 0:
			gex["select"].add_child(walk_check)
			await get_tree().process_frame
			await get_tree().physics_frame
			check_walk_area = gex["select"].get_node("walk_check").get_overlapping_areas()
			check_area(check_walk_area, lvl_start)
		else:
			if walk["go"].size() > 0:
				walk_go_copy = walk["go"].duplicate()
				for wgc in walk_go_copy:
					walk_check.global_position = wgc.global_position
					await get_tree().process_frame
					await get_tree().physics_frame
					check_walk_area = gex["select"].get_node("walk_check").get_overlapping_areas()
					check_area(check_walk_area, lvl_start)
		speed -= 1
		ring += 1
	
	await get_tree().process_frame
	await get_tree().physics_frame
	if gex["select"].has_node("walk_check"):
		gex["select"].get_node("walk_check").queue_free()
		await get_tree().process_frame
		await get_tree().physics_frame
	
	if walk["go"].size() > 0:
		for wg in walk["go"]:
			var pipe_go = object["pipe_go"].instantiate()
			pipe_go.name = "pipe_go"
			if !wg.has_node("pipe_go"):
				wg.add_child(pipe_go)
	
	if walk["attack"].size() > 0:
		for wa in walk["attack"]:
			var pipe_attack = object["pipe_attack"].instantiate()
			pipe_attack.name = "pipe_attack"
			if !wa.has_node("pipe_attack"):
				wa.add_child(pipe_attack)
	
	flag["hard_work"] = false

func buy(figura_buy_name):
	if !flag["you_turn"] or players_user[multiplayer.get_unique_id()]["kazna"] < figura_parametr[figura_buy_name][2] or have_tusk == 0:
		return
	if flag["hard_work"]:
		return
	flag["hard_work"] = true
	flag["buy"] = true
	
	$USER/UI/Kazna_W.hide()
	gex["buy_ghost"] = figura[figura_buy_name].instantiate()
	gex["buy_ghost"].name = "buy_ghost"
	add_child(gex["buy_ghost"])
	await get_tree().process_frame
	gex["buy_ghost"].set_meta("fig_buy_name", figura_buy_name)
	flag["hard_work"] = false

func action_cansel():
	if flag["hard_work"]:
		return
	flag["hard_work"] = true
	
	gex["effect_select"].global_position = gex["effect_holder"].global_position
	gex["effect_rotate"].global_position = gex["effect_holder"].global_position
	
	for f in action_flag:
		flag[f] = false
	
	for w in walk.keys():
		if walk[w].size() > 0:
			for w2 in walk[w]:
				var pipes = TABLE.find_children("pipe_"+w, "", true, false)
				for p in pipes:
					p.queue_free()
		walk[w] = []
	
	if gex["buy_ghost"]:
		gex["buy_ghost"].queue_free()
	flag["buy_ok"] = false
	
	flag["hard_work"] = false

func check_lvl(lvl):
	match lvl:
		"A" : return(3)
		"B" : return(2)
		_ : return(1)

func check_speed():
	for fp in figura_parametr.keys():
		if gex["select"].is_in_group(fp):
			return figura_parametr[fp][0]

func check_area(check_walk_area, lvl_start):
	for ck in check_walk_area:
		var gex_clear := true
		for fp in figura_parametr.keys():
			if ck.is_in_group(fp):
				gex_clear = false
				for pu in players_user.keys():
					if ck.is_in_group(players_user[pu]["username"]) and !ck.is_in_group(C.USERNAME) and ck.is_in_group(C.USERNAME+"_power"):
						walk["attack"].append(ck)
						break
		
		if gex_clear:
			if !walk["go"].has(ck) and (check_lvl(ck.get_parent().get_name()) - lvl_start) < 2:
				if check_lvl(ck.get_parent().get_name()) - lvl_start == 1:
					if have_tusk == 2:
						walk["go"].append(ck)
				else:
					walk["go"].append(ck)

func pick_first_turn():
	flag["first_turn"] = true
	if active_user.size() == 0:
		var messege = "\n"+"[color=green]"+"НЕТ ИГРОКОВ"+"[/color]"
		rpc("send_chat", messege)
		return
	first_turn_name = active_user.pick_random()
	active_user.erase(first_turn_name)
	active_user.insert(0, first_turn_name)
	
	rpc("send_turn", active_user, flag["first_turn"])
#endregion

func pick_karta():
	pass




















































































































































































#
