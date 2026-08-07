extends Node
var M_BEAR = preload("res://visual/material/king/mBear.tres")
var M_BULL = preload("res://visual/material/king/mBull.tres")
var M_DRAGON = preload("res://visual/material/king/mDragon.tres")
var M_EAGLE = preload("res://visual/material/king/mEagle.tres")
var M_ELEPHANT = preload("res://visual/material/king/mElephant.tres")
var M_LION = preload("res://visual/material/king/mLion.tres")

const walk_material = preload("res://visual/material/game/walk.tres")
const attack_material = preload("res://visual/material/game/attack.tres")
const king_gerb = [null, null, preload("res://king/gerb/Bear.png"), preload("res://king/gerb/Bull.png"), preload("res://king/gerb/Dragon.png"), preload("res://king/gerb/Eagle.png"), preload("res://king/gerb/Elephant.png"), preload("res://king/gerb/Lion.png")]
const kazna_ico = [preload("res://koloda/kazna/K_00.png"), preload("res://koloda/kazna/K_00_Op.png"), preload("res://koloda/kazna/K_1.png"), preload("res://koloda/kazna/K_1_Op.png"), preload("res://koloda/kazna/K_2.png"), preload("res://koloda/kazna/K_2_Op.png"), preload("res://koloda/kazna/K_3.png"), preload("res://koloda/kazna/K_3_Op.png"), preload("res://koloda/kazna/K_4.png"), preload("res://koloda/kazna/K_4_Op.png")]
const bay_material = [preload("res://visual/material/figura/buy_bad.tres"), preload("res://visual/material/figura/buy_good.tres")]
const cute_cube = preload("res://mesh_figura/cute_cube.tscn")

var kazna_ico_select = 0

var fon_flat = [preload("res://visual/material/market/fon_flat.tres"), preload("res://visual/material/market/fon_flat_2.tres")]

var hard_work = false

var input_cooldown = 0

var maxWind = 0.2
var wind = maxWind
var rot = 0
var select_gex
var forward_gex
var select_figure

var walk_check = preload("res://mesh_figura/walk_check.tscn")
var walk_pipe = preload("res://lvl/game/walk_pipe.tscn")
var attack_pipe = preload("res://lvl/game/attack_pipe.tscn")
var walk_ready = []
var walk_attack = []

var you_turn = false
var king_alive = true
var buy_flag = false
var buy_ghost
var bay_ok = false


var rotate_system_active = false
var gex_effect
var rotate_system_v2


var active_player = []
var kazna_player = {}

var players_group = []
var players_user := {}

var lobby_parametrs = {}

var have_tusk = 0



const figura_param := {
	#name : [speed, attack, price, win, material]
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


@onready var table: Node3D = $WORLD/TABLE

func _ready() -> void:
	if R.status == "CLIENT":
		lobby_parametrs = C.lobby_scene.lobby_parametrs
		players_user = C.lobby_scene.players_user
	elif R.status == "SERVER_GAME":
		lobby_parametrs = SG.lobby_parametrs
		players_user = SG.players_user
		randomize()
		return
	UI_connect()


func _process(delta: float) -> void:
	if R.status == "CLIENT" and C.in_game and !$USER/UI/CHAT/VB/panel/Box/LineEdit.has_focus():
		if input_cooldown > 0:
			input_cooldown -= 0.1
		if C.lobby_scene.visible == false:
			if rotate_system_active:
				rotate_system()
			$USER/cam_piv_1/cam_piv_2.rotation_degrees.x += (rot - $USER/cam_piv_1/cam_piv_2.rotation_degrees.x)/12
			if Input.is_action_pressed("A"):
				$USER/cam_piv_1.rotation_degrees.y -= 0.55
			elif Input.is_action_pressed("D"):
				$USER/cam_piv_1.rotation_degrees.y += 0.55


func _input(event):
	if R.status == "CLIENT" and C.in_game and $USER/UI/CHAT/VB/panel/Box/LineEdit.has_focus():
		if event is InputEventKey and event.is_action_pressed("esc"):
			$USER/UI/CHAT/VB/panel/Box/LineEdit.release_focus()
		#elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#	$USER/UI/CHAT/VB/panel/Box/LineEdit.release_focus()
	
	if R.status == "CLIENT" and C.in_game and !$USER/UI/CHAT/VB/panel/Box/LineEdit.has_focus():
		if C.lobby_scene.visible == false:
			if rotate_system_active:
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and input_cooldown <= 0:
					Audio._on_ui_click()
					rpc("rotate_system_server", select_gex.get_path(), select_gex.rotation.y)
					rotate_system_active = false
					hard_work = false
					await get_tree().create_timer(0.5).timeout
					#rpc("update_power")
					select_gex.position.y = 0
					select_gex = null
					await get_tree().create_timer(1).timeout
					cansel_walk()
				#return
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					for i in range(15):
						await get_tree().process_frame
						$USER/cam_piv_1.rotation_degrees.y += 0.25
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					for i in range(15):
						await get_tree().process_frame
						$USER/cam_piv_1.rotation_degrees.y -= 0.25
				elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
					rot = -40
					cam_down()
				elif !event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
					rot = 0
					cam_up()
				elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT and input_cooldown <= 0:
					Audio._on_ui_click()
					if buy_flag and bay_ok and buy_ghost.has_meta("figura_buy_name") and have_tusk > 0 and !hard_work:
						select_gex = forward_gex
						rpc_id(1, "figura_buy_server", buy_ghost.get_meta("figura_buy_name"), select_gex.get_path())
						print("TASK!! ", have_tusk)
						have_tusk -= 1
						print("TASK!! ", have_tusk)
						select_gex.position.y = 0.05
						cansel_walk()
						await get_tree().create_timer(0.1).timeout
						#rpc("update_power")
						rotate_system_active = true
						
						input_cooldown = 6
						return
					if forward_gex and forward_gex.is_in_group(C.USERNAME) and have_tusk > 0 and select_gex != forward_gex and !hard_work:
						print("figure_go")
						if forward_gex:
							cansel_walk()
						figure_go()
						
						input_cooldown = 6
						return
					if forward_gex and forward_gex.is_in_group(C.USERNAME) and have_tusk > 0 and select_gex == forward_gex and !hard_work and !rotate_system_active:
						have_tusk -= 1
						rotate_system_active = true
						
						input_cooldown = 6
						return
					if forward_gex and (forward_gex.get_node_or_null("walk_pipe") or forward_gex.get_node_or_null("attack_pipe")) and have_tusk > 0 and select_gex != forward_gex and !hard_work and !rotate_system_active:
						if forward_gex.get_node_or_null("walk_pipe"):
							if king_alive:
								print("этаж ", check_lvl(select_gex.get_parent().get_name()) - check_lvl(forward_gex.get_parent().get_name()))
								if check_lvl(forward_gex.get_parent().get_name()) - check_lvl(select_gex.get_parent().get_name()) == 1:
									have_tusk -= 2
								else:
									have_tusk -= 1
							else:
								have_tusk -= 2
							rpc("figure_go_server", select_gex.get_path(), forward_gex.get_path())
							await get_tree().create_timer(0.1).timeout
							#rpc("update_power")
							cansel_walk()
						elif forward_gex.get_node_or_null("attack_pipe"):
							have_tusk -= 2
							rpc("figure_attack_server", select_gex.get_path(), forward_gex.get_path())
							await get_tree().create_timer(0.1).timeout
							#rpc("update_power")
							cansel_walk()
						
						input_cooldown = 6
						return
					
					input_cooldown = 6
					return
			elif event is InputEventKey:
				if event.is_action_pressed("W"):
					rot = -40
					cam_down()
				elif event.is_action_released("W"):
					rot = 0
					cam_up()
				elif event.is_action("esc"):
					pass
					cansel_walk()


func cam_down():
	for i in range(15):
		await get_tree().process_frame
		if $USER/cam_piv_1.global_position.y > -0.3:
			$USER/cam_piv_1.global_position.y -= 0.02

func cam_up():
	for i in range(15):
		await get_tree().process_frame
		if $USER/cam_piv_1.global_position.y < 0:
			$USER/cam_piv_1.global_position.y += 0.02



@rpc("authority", "call_local", "reliable")
func spawn_start():
	if R.status == "CLIENT":
		for u in players_user:
			if players_user[u]["username"] == C.USERNAME:
				#print("TEEESTTTTTT")
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
		players_group.append(players_user[u]["username"])
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
		
		
		active_player.append(u)
		kazna_player[u] = 0
		#print(active_player.size())
		monolit(u)
		
		var gex = "D_"+spawn
		figure_spawn(players_user[u], "king", table.get_node(gex+"/GEX").get_path())
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX2").get_path())
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX3").get_path())
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX4").get_path())
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX5").get_path())
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX6").get_path())
	
	if R.status == "SERVER_GAME":
		$USER/UI/CHAT/VB/panel/Box/chat.append_text("\n SERVER_GAME")
		await get_tree().create_timer(0.1).timeout
		random_first_turn()
		for u in players_user:
			kazna_dodep(u, 999)
		rpc("kazna_update", players_user)
		rpc("update_power")

@rpc("authority", "call_local", "reliable")
func figure_spawn(player, figure, gex_path):
	var gex = get_node(gex_path)
	var player_gex = player["king"]
	match player_gex:
		"2" : player_gex = "bear"
		"3" : player_gex = "bull"
		"4" : player_gex = "dragon"
		"5" : player_gex = "eagle"
		"6" : player_gex = "elephant"
		"7" : player_gex = "lion"
		_ : return
	var instance = figura[figure].instantiate()
	var instance2 = MeshInstance3D.new()
	
	instance2.mesh = figura["gex_"+player_gex]
	instance2.name = "pad"
	
	if !gex.get_groups():
		gex.add_child(instance)
		gex.add_child(instance2)
		gex.add_to_group(player["username"])
		gex.add_to_group(figure)
		if figure == "king":
			var instance3 = figura["flag_"+player_gex].instantiate()
			gex.get_node("king").add_child(instance3)

func monolit(u):
	var king = int(players_user[u]["king"])
	match players_user[u]["spawn"]:
		"2" : 
			$WORLD/monolit_players/monolit_1.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_1.get_node("info").visible = true
			$WORLD/monolit_players/monolit_1.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"3" : 
			$WORLD/monolit_players/monolit_2.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_2.get_node("info").visible = true
			$WORLD/monolit_players/monolit_2.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"4" : 
			$WORLD/monolit_players/monolit_3.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_3.get_node("info").visible = true
			$WORLD/monolit_players/monolit_3.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"5" : 
			$WORLD/monolit_players/monolit_4.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_4.get_node("info").visible = true
			$WORLD/monolit_players/monolit_4.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"6" : 
			$WORLD/monolit_players/monolit_5.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_5.get_node("info").visible = true
			$WORLD/monolit_players/monolit_5.get_node("info").get_node("username_label").text = str(players_user[u]["username"])
		"7" : 
			$WORLD/monolit_players/monolit_6.get_node("info").get_node("gerb").mesh.surface_get_material(0).albedo_texture = king_gerb[king]
			$WORLD/monolit_players/monolit_6.get_node("info").visible = true
			$WORLD/monolit_players/monolit_6.get_node("info").get_node("username_label").text = str(players_user[u]["username"])

func ava_update(ava_name):
	if R.status == "SERVER_GAME":
		return
	
	var avatar = AccData.avatar_from_base64(C.avatar_user[ava_name])
	if avatar == null:
		avatar = preload("res://import/ava_placehold.png")
	for u in players_user:
		if ava_name == players_user[u]["username"]:
			match players_user[u]["spawn"]:
				"2" : $WORLD/monolit_players/monolit_1.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"3" : $WORLD/monolit_players/monolit_2.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"4" : $WORLD/monolit_players/monolit_3.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"5" : $WORLD/monolit_players/monolit_4.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"6" : $WORLD/monolit_players/monolit_5.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar
				"7" : $WORLD/monolit_players/monolit_6.get_node("info").get_node("avatar").mesh.surface_get_material(0).albedo_texture = avatar

func gex_entered(gex):
	print("GEX: ", gex, " Группы: ", str(gex.get_groups()))
	#print(have_tusk)
	if gex.is_in_group(C.USERNAME):
		gex.position.y = 0.05
	forward_gex = gex
	if buy_flag:
		buy_ghost.global_position = gex.global_position
		if buy_ghost.get_meta("figura_buy_name") == "peshk" :
				var power_other = false
				if gex.is_in_group(C.USERNAME+"_power"):
					for g in gex.get_groups():
						if g.ends_with("_power") and g != str(C.USERNAME+"_power"):
							power_other = true
					if !power_other:
						buy_ghost.get_node("mesh").set_surface_override_material(0, bay_material[1])
						bay_ok = true
					else:
						buy_ghost.get_node("mesh").set_surface_override_material(0, bay_material[0])
						bay_ok = false
				else:
					buy_ghost.get_node("mesh").set_surface_override_material(0, bay_material[0])
					bay_ok = false
		else:
			if gex.is_in_group(figura_param[buy_ghost.get_meta("figura_buy_name")][4]) and gex.is_in_group(C.USERNAME):
				buy_ghost.get_node("mesh").set_surface_override_material(0, bay_material[1])
				bay_ok = true
				gex.get_node(figura_param[buy_ghost.get_meta("figura_buy_name")][4]).visible = false
			else:
				buy_ghost.get_node("mesh").set_surface_override_material(0, bay_material[0])
				bay_ok = false
			

func gex_exited(gex):
	if gex.is_in_group(C.USERNAME) and gex != select_gex:
		gex.position.y = 0.0
	if buy_flag:
		for f in figura_param.keys():
			if gex.is_in_group(f):
				gex.get_node(f).visible = true



func figure_go():
	if hard_work:
		return
	walk_ready.clear()
	walk_attack.clear()
	hard_work = true
	print("figure_go")
	select_gex = forward_gex
	select_gex.position.y = 0.05
	gex_effect.global_position = select_gex.global_position
	rotate_system_v2.global_position = select_gex.global_position
	var lvl_start = check_lvl(select_gex.get_parent().get_name())
	var speed = 0
	var krug = 1
	var walk_ready_copy
	for f in figura_param.keys():
		if select_gex.is_in_group(f):
			speed = figura_param[f][0]
			break
	var child_walk_check = walk_check.instantiate()
	child_walk_check.name = "walk_check"
	while speed > 0 :
		print("speed "+str(speed))
		print("krug "+str(krug))
		var check_walk_area
		if krug == 1: 
			#var child_walk_check = walk_check.instantiate()
			#child_walk_check.name = "walk_check"
			select_gex.add_child(child_walk_check)
			await get_tree().create_timer(0.03).timeout
			check_walk_area = select_gex.get_node("walk_check").get_overlapping_areas()
			#await get_tree().create_timer(0.05).timeout
			check_walk_area(check_walk_area, lvl_start)
			#select_gex.get_node("walk_check").queue_free()
			#await get_tree().create_timer(0.05).timeout
		else: 
			#print("elif krug > 1:!!!!!!! _walk_ ", walk_ready)
			if walk_ready.size() > 0:
				walk_ready_copy = walk_ready.duplicate()
				await get_tree().create_timer(0.03).timeout
				#print("VTOROY KRYG!! walk_ready_copy_ ", walk_ready_copy)
				#print("VTOROY KRYG!! walk_ready_ ", walk_ready)
				for w in walk_ready_copy:
					#var child_walk_check = walk_check.instantiate()
					#child_walk_check.name = "walk_check"
					child_walk_check.global_position = w.global_position
					await get_tree().create_timer(0.03).timeout
					#w.add_child(child_walk_check)
					#await get_tree().create_timer(0.05).timeout
					#check_walk_area = w.get_node("walk_check").get_overlapping_areas()
					check_walk_area = select_gex.get_node("walk_check").get_overlapping_areas()
					check_walk_area(check_walk_area, lvl_start)
					#w.get_node("walk_check").queue_free()
					#await get_tree().create_timer(0.05).timeout
		speed -= 1
		krug += 1
	####
	await get_tree().process_frame
	select_gex.get_node("walk_check").queue_free()
	await get_tree().process_frame
	####
	if walk_ready.size() > 0:
		for w in walk_ready:
			if w:
				var pipe = walk_pipe.instantiate()
				pipe.name = "walk_pipe"
				w.add_child(pipe)
		if walk_attack.size() > 0:
			for w2 in walk_attack:
				var pipe2 = attack_pipe.instantiate()
				pipe2.name = "attack_pipe"
				w2.add_child(pipe2)
	hard_work = false

func check_lvl(lvl):
	match lvl:
		"A" : return(3)
		"B" : return(2)
		_ : return(1)

func check_walk_area(check_walk_area, lvl_start):
	#print("check_walk_area_ ", check_walk_area)
	for w in check_walk_area:
		#print("check_walk_area_DOP: ", check_walk_area, "w: ", w, "tusk: ", have_tusk)
		var gex_clear = true
		#вот тут менял!
		for n in figura_param.keys():
			if w.is_in_group(n):
				for n2 in active_player:
					if w.is_in_group(players_user[n2]["username"]) and !w.is_in_group(C.USERNAME) and w.is_in_group(C.USERNAME+"_power"):
						walk_attack.append(w)
				gex_clear = false
				break
		if gex_clear:
			if !walk_ready.has(w) and check_lvl(w.get_parent().get_name()) - lvl_start < 2:
				if check_lvl(w.get_parent().get_name()) - lvl_start == 1:
					if have_tusk == 2:
						walk_ready.append(w)
						#print("ДОБАВЛЕНО have_tusk == 2! ", walk_ready)
				else: 
					walk_ready.append(w)
					#print("ДОБАВЛЕНО else!! ", walk_ready)

func cansel_walk():
	if hard_work:
		return
	if !rotate_system_active:
		gex_effect.global_position = $WORLD/gex_effect_holder.global_position
	rotate_system_v2.global_position = $WORLD/gex_effect_holder.global_position
	print("cansel_walk")
	#if select_gex and select_gex.get_node_or_null("gex_effect"):
	#	select_gex.get_node("gex_effect").free()
	if select_gex:
		select_gex.position.y = 0.0
	if walk_ready.size() > 0:
		for w in walk_ready:
			var pipes = $WORLD/TABLE.find_children("walk_pipe", "", true, false)
			for p in pipes:
				if p:
					p.free()
					await get_tree().process_frame
	if walk_attack.size() > 0:
		for w2 in walk_attack:
			var pipes = $WORLD/TABLE.find_children("attack_pipe", "", true, false)
			for p in pipes:
				if p:
					p.free()
					await get_tree().process_frame
	if buy_flag:
		buy_flag = false
		buy_ghost.free()


func rotate_system():
	#print("ROOOOTAAAATEEEE!! process")
	hard_work = true
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var plane_y = select_gex.global_position.y
	if dir.y == 0:
		return
	var t = (plane_y - from.y) / dir.y
	if t <= 0:
		return
	var hit_point = from + dir * t
	var to_cursor = hit_point - select_gex.global_position
	to_cursor.y = 0
	if to_cursor.length() < 0.001:
		return
	var angle = atan2(to_cursor.x, to_cursor.z)
	var step = deg_to_rad(60)
	var snapped_angle = round(angle / step) * step
	select_gex.rotation.y = snapped_angle




@rpc("any_peer", "call_local", "reliable")
func figure_go_server(select_gex_path, forward_gex_path):
	var sender = multiplayer.get_remote_sender_id()
	hard_work = true
	var select_gex_server = get_node(select_gex_path)
	var forward_gex_server = get_node(forward_gex_path)
	print("figure_go_server!")
	
	select_gex_server.get_node("pad").reparent(forward_gex_server, false)
	for f in figura_param.keys():
		if select_gex_server.is_in_group(f):
			select_gex_server.get_node(f).reparent(forward_gex_server, false)
			select_gex_server.remove_from_group(players_user[active_player[0]]["username"])
			select_gex_server.remove_from_group(f)
			forward_gex_server.add_to_group(players_user[active_player[0]]["username"])
			forward_gex_server.add_to_group(f)
			hard_work = false
			if R.status == "CLIENT":
				await get_tree().process_frame
				#gex_effect.global_position = forward_gex_server.global_position
				#gex_effect.anim()
				if sender == multiplayer.get_unique_id():
					await get_tree().create_timer(0.1).timeout
					select_gex = forward_gex_server
					rotate_system_v2.global_position = forward_gex_server.global_position
					rotate_system_active = true
					select_gex.position.y = 0.05
			break
	rpc("update_power")

@rpc("any_peer", "call_local", "reliable")
func rotate_system_server(forward_gex_path, rotate):
	print("rotate_SERVER")
	var forward_gex_server = get_node(forward_gex_path)
	forward_gex_server.rotation.y = rotate
	if R.status == "CLIENT":
		gex_effect.global_position = forward_gex_server.global_position
		gex_effect.anim()
	rpc("update_power")

@rpc("any_peer", "call_local", "reliable")
func figure_attack_server(select_gex_path, forward_gex_path):
	var sender = multiplayer.get_remote_sender_id()
	#hard_work = true
	rpc("update_power")

@rpc("any_peer", "call_local", "reliable")
func figura_buy_server(figura_buy_name_s, select_gex_path):
	var sender = multiplayer.get_remote_sender_id()
	var select_gex_server = get_node(select_gex_path)
	if multiplayer.is_server():
		print("Игрок: ", players_user[sender]["username"], " купил: ", figura_buy_name_s,)
		players_user[sender]["kazna"] -= figura_param[figura_buy_name_s][2]
		rpc("figure_spawn", players_user[sender], figura_buy_name_s, select_gex_path)
		rpc("kazna_update", players_user)
	rpc("update_power")

@rpc("authority", "call_local", "reliable")
func kazna_update(players_user_update):
	if multiplayer.is_server():
		return
	for u in players_user_update:
		for u2 in players_user:
			if u == u2:
				players_user[u2]["kazna"] = players_user_update[u]["kazna"]
				break
	
	var you_kazna = players_user[multiplayer.get_unique_id()]["kazna"]
	$USER/UI/Kazna_b/Count_l.text = str(you_kazna)
	if you_kazna <= 0:
		kazna_ico_select = 0
	elif you_kazna > 0 and you_kazna < 12:
		kazna_ico_select = 2
	elif you_kazna >= 12 and you_kazna < 24:
		kazna_ico_select = 4
	elif you_kazna >= 24 and you_kazna < 36:
		kazna_ico_select = 6
	elif you_kazna > 36:
		kazna_ico_select = 8
	else:
		kazna_ico_select = 0
	$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	Audio.Action_sound_play("kazna")

func kazna_dodep(user, count):
	players_user[user]["kazna"] += count
	

@rpc("authority", "call_local", "reliable")
func phase_day():
	pass

@rpc("authority", "call_local", "reliable")
func player_turn():
	if active_player.size() == 0:
		return
	
	var player = active_player[0] 
	$USER/UI/player_turn_go.text = str(players_user[player]["username"])+" - ходи уже"

@rpc("any_peer", "call_local", "reliable")
func send_chat(text):
	$USER/UI/CHAT/VB/panel/Box/chat.append_text(text)

func chat(text):
	$USER/UI/CHAT/VB/panel/Box/LineEdit.clear()
	$USER/UI/CHAT/VB/panel/Box/LineEdit.release_focus()
	var messege = "\n"+"[color=#c9001e]"+str(C.USERNAME)+"[/color]: "+str(text)
	rpc("send_chat", messege)

func random_first_turn():
	if active_player.size() == 0:
		var messege = "\n"+"[color=red]"+"НЕТ ИГРОКОВ"+"[/color]"
		rpc("send_chat", messege)
		return
	var first = active_player.pick_random()
	active_player.erase(first)
	active_player.insert(0, first)
	rpc("send_turn", active_player)
	var messege = "\n"+"[color=green]"+"СЕРВЕР: ХОД ИГРОКА "+str(players_user[first]["username"])+"[/color]"
	rpc("send_chat", messege)

func kazna_nx(nx):
	if nx == "entered":
		kazna_ico_select += 1
		$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	elif nx == "exited":
		kazna_ico_select -= 1
		$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	elif nx == "open":
		cansel_walk()
		$USER/UI/Kazna_W.popup()

func close_window(window):
	match window:
		"info" : $USER/UI/Info_W.hide()
		"kazna" : $USER/UI/Kazna_W.hide()

func UI_connect():
	gex_effect = $WORLD/gex_effect_holder/gex_effect
	rotate_system_v2 = $WORLD/gex_effect_holder/rotate_system_v2
	
	$USER/UI/player_turn_go.pressed.connect(func(): 
		have_tusk += 2 
		print(have_tusk)
		)
	
	$USER/UI/CHAT/VB/HButton/Plus_chat.pressed.connect(func(): $USER/UI/CHAT.size += Vector2(25, 25))
	$USER/UI/CHAT/VB/HButton/Minus_chat.pressed.connect(func(): $USER/UI/CHAT.size -= Vector2(25, 25))
	
	$USER/UI/CHAT/VB/panel/Box/LineEdit.text_submitted.connect(chat)
	
	$USER/UI/Kazna_b.pressed.connect(kazna_nx.bind("open"))
	$USER/UI/Kazna_b.mouse_entered.connect(kazna_nx.bind("entered"))
	$USER/UI/Kazna_b.mouse_exited.connect(kazna_nx.bind("exited"))
	$USER/UI/Info_W.close_requested.connect(close_window.bind("info"))
	$USER/UI/Kazna_W.close_requested.connect(close_window.bind("kazna"))
	$USER/UI/Info_W.focus_exited.connect(close_window.bind("info"))
	$USER/UI/Kazna_W.focus_exited.connect(close_window.bind("kazna"))
	
	await get_tree().create_timer(1.0).timeout
	for option in $USER/UI/Kazna_W/Magaz/VBox/Options.get_children():
		var name = option.name
		option.get_node("Adept/Fon").add_theme_stylebox_override("panel", preload("res://visual/material/market/fon_flat.tres"))
		option.get_node("Fanat/Fon").add_theme_stylebox_override("panel", preload("res://visual/material/market/fon_flat.tres"))
		
		option.get_node("Adept/Button").pressed.connect(buy_figura.bind(name))
		option.get_node("Fanat/Button").pressed.connect(buy_figura.bind(name+"fan"))
		option.get_node("Adept/Button").mouse_entered.connect(func(): option.get_node("Adept/Fon").add_theme_stylebox_override("panel", fon_flat[1]))
		option.get_node("Fanat/Button").mouse_entered.connect(func(): option.get_node("Fanat/Fon").add_theme_stylebox_override("panel", fon_flat[1]))
		option.get_node("Adept/Button").mouse_exited.connect(func(): option.get_node("Adept/Fon").add_theme_stylebox_override("panel", fon_flat[0]))
		option.get_node("Fanat/Button").mouse_exited.connect(func(): option.get_node("Fanat/Fon").add_theme_stylebox_override("panel", fon_flat[0]))
	
	
	$USER/UI/Kazna_W/Magaz/VBox/Info/Info_button.pressed.connect(func(): $USER/UI/Info_W.popup())

func buy_figura(figura_buy_name):
	if !you_turn or players_user[multiplayer.get_unique_id()]["kazna"] < figura_param[figura_buy_name][2] or have_tusk < 1:
		return
	hard_work = true
	buy_flag = true
	$USER/UI/Kazna_W.hide()
	print(figura_buy_name)
	buy_ghost = figura[figura_buy_name].instantiate()
	buy_ghost.name = "buy_ghost"
	add_child(buy_ghost)
	await get_tree().process_frame
	buy_ghost.set_meta("figura_buy_name", figura_buy_name)
	hard_work = false


@rpc("authority", "call_local", "reliable")
func send_turn(active_player):
	if R.status == "CLIENT":
		if str(C.USERNAME) == str(players_user[active_player[0]]["username"]):
			you_turn = true
			$USER/UI/Turn_W.popup()
			have_tusk = 2
			$USER/UI/player_turn_go.text = "ЗАВЕРШИТЬ ХОД"
		else:
			$USER/UI/player_turn_go.text = str(players_user[active_player[0]]["username"])+" - ходи уже"


@rpc("any_peer", "call_local", "reliable")
func update_power():
	for u in players_user.keys():
		players_user[u]["kazna_power"] = 0
	
	var allgex = $WORLD/TABLE.find_children("GEX*")
	print("ALLLLLLL ", allgex)
	for gedel in allgex:
		var cube_del = gedel.find_children("cute_cube")
		print("cube_del.size!!!!!! ", cube_del.size())
		if cube_del.size() > 0:
			for cube_del2 in cube_del:
				cube_del2.free()
				print("КУБИКА УБИЛИ!")
		for gpdel in gedel.get_groups():
			if gpdel.ends_with("_power"):
				gedel.remove_from_group(gpdel)
				print("ГРУППА УДАЛЕНА ", gpdel)
	
	await get_tree().create_timer(0.5).timeout
	
	for ge in allgex:
		for u in players_user.keys():
			if ge.is_in_group(players_user[u]["username"]):
				for f in figura_param.keys():
					if ge.is_in_group(f):
						var gex_power_list = ge.get_node(f).get_node("attack").get_overlapping_areas()
						for gpl in gex_power_list:
							gpl.add_to_group(players_user[u]["username"]+"_power")
						continue
	
	await get_tree().create_timer(0.5).timeout
	
	for ge2 in allgex:
		var power_groups = []
		for gp in ge2.get_groups():
			if gp.ends_with("_power"):
				power_groups.append(gp)
		if power_groups.size() == 1:
			var username = power_groups[0].split("_power")[0]
			for u in players_user.keys():
				if players_user[u]["username"] == username:
					players_user[u]["kazna_power"] += 1
					var cute_cube_spawn = cute_cube.instantiate()
					cute_cube_spawn.name = "cute_cube"
					if !multiplayer.is_server():
						var material_cube
						match players_user[u]["king"]:
							"2" : material_cube = M_BEAR
							"3" : material_cube = M_BULL
							"4" : material_cube = M_DRAGON
							"5" : material_cube = M_EAGLE
							"6" : material_cube = M_ELEPHANT
							"7" : material_cube = M_LION
							_ : return
						cute_cube_spawn.get_node("cube").set_surface_override_material(0, material_cube)
					if !ge2.has_node("cute_cube") and !ge2.has_node("pad"):
						ge2.add_child(cute_cube_spawn)
					continue

















































#
