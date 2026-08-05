extends Node

const walk_material = preload("res://visual/material/game/walk.tres")
const attack_material = preload("res://visual/material/game/attack.tres")
const king_gerb = [null, null, preload("res://king/gerb/Bear.png"), preload("res://king/gerb/Bull.png"), preload("res://king/gerb/Dragon.png"), preload("res://king/gerb/Eagle.png"), preload("res://king/gerb/Elephant.png"), preload("res://king/gerb/Lion.png")]

const kazna_ico = [preload("res://koloda/kazna/K_00.png"), preload("res://koloda/kazna/K_00_Op.png"), preload("res://koloda/kazna/K_1.png"), preload("res://koloda/kazna/K_1_Op.png"), preload("res://koloda/kazna/K_2.png"), preload("res://koloda/kazna/K_2_Op.png"), preload("res://koloda/kazna/K_3.png"), preload("res://koloda/kazna/K_3_Op.png"), preload("res://koloda/kazna/K_4.png"), preload("res://koloda/kazna/K_4_Op.png")]
var kazna_ico_select = 0

var fon_flat = [preload("res://visual/material/market/fon_flat.tres"), preload("res://visual/material/market/fon_flat_2.tres")]

var maxWind = 0.2
var wind = maxWind
var rot = 0
var select_gex
var forward_gex
var select_figure

var active_player = []
var kazna_player = {}

var players_group = []
var players_user := {}

var lobby_parametrs = {}

const figura_name := ["king", "peshk", "peshk_fan", "kon", "kon_fan", "slon", "slon_fan", "lada", "lada_fan", "lada_fan_ready"]

const figura_speed := {
	"king" : 1,
	"peshk" : 2,
	"peshk_fan" : 2,
	"kon" : 3,
	"kon_fan" : 3,
	"slon" : 2,
	"slon_fan" : 2,
	"lada" : 1,
	"lada_fan" : 1,
	"lada_fan_ready" : 1,
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
		lobby_parametrs = SG.lobby_scene.lobby_parametrs
		players_user = SG.lobby_scene.players_user
		randomize()
		return
	
	magaz_connect()
	
	
	
	

func _process(delta: float) -> void:
	if R.status == "CLIENT" and C.in_game:
		if C.lobby_scene.visible == false:
			$USER/cam_piv_1/cam_piv_2.rotation_degrees.x += (rot - $USER/cam_piv_1/cam_piv_2.rotation_degrees.x)/12
			if Input.is_action_pressed("A"):
				$USER/cam_piv_1.rotation_degrees.y -= 0.55
			elif Input.is_action_pressed("D"):
				$USER/cam_piv_1.rotation_degrees.y += 0.55


func _input(event):
	if R.status == "CLIENT" and C.in_game:
		if C.lobby_scene.visible == false:
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
			elif event is InputEventKey:
				if event.is_action_pressed("W"):
					rot = -40
					cam_down()
				elif event.is_action_released("W"):
					rot = 0
					cam_up()
				#elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					#if forward_gex.is_in_group(C.USERNAME):
					#	figure_go()

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
		var player_gex = players_user[u]["king"]
		players_group.append(players_user[u]["username"])
		
		
		match spawn:
			"2" : spawn = "A"
			"3" : spawn = "B"
			"4" : spawn = "C"
			"5" : spawn = "D"
			"6" : spawn = "E"
			"7" : spawn = "F"
			_ : spawn = ""
		
		match player_gex:
			"2" : player_gex = "bear"
			"3" : player_gex = "bull"
			"4" : player_gex = "dragon"
			"5" : player_gex = "eagle"
			"6" : player_gex = "elephant"
			"7" : player_gex = "lion"
			_ : player_gex = ""
		
		if spawn == "":
			continue
		if player_gex == "":
			continue
		
		
		active_player.append(u)
		kazna_player[u] = 0
		#print(active_player.size())
		monolit(u)
		
		var gex = "D_"+spawn
		figure_spawn(players_user[u], "king", table.get_node(gex+"/GEX"), player_gex)
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX2"), player_gex)
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX3"), player_gex)
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX4"), player_gex)
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX5"), player_gex)
		figure_spawn(players_user[u], "peshk", table.get_node(gex+"/GEX6"), player_gex)

func figure_spawn(player, figure, gex, player_gex):
	var instance = figura[figure].instantiate()
	var instance2 = MeshInstance3D.new()
	
	instance2.mesh = figura["gex_"+player_gex]
	if !gex.get_groups():
		gex.add_child(instance)
		gex.add_child(instance2)
		gex.add_to_group(player["username"])
		if figure == "king":
			var instance3 = figura["flag_"+player_gex].instantiate()
			gex.get_node("king").add_child(instance3)

func monolit(u):
	#var avatar = preload("res://import/ava_placehold.png")
	#if !players_user[u]["avatar"] == null:
		#avatar = AccData.avatar_from_base64(players_user[u]["avatar"])
	
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
	if gex.is_in_group(C.USERNAME):
		gex.position.y = 0.05
	forward_gex = gex

func gex_exited(gex):
	if gex.is_in_group(C.USERNAME) and gex != select_gex:
		gex.position.y = 0.0

func figure_go():
	pass

@rpc("authority", "call_local", "reliable")
func phase_day():
	pass


#func figure_go():
	#select_gex = forward_gex
	#select_gex.position.y = 0.05
	#for n in figura_name:
		#if select_gex.has_node(n):
			#select_figure = select_gex.get_node(n)
			#print("bingo")
	#
	#
	#var walk_area = select_figure.get_node("walk")
	#var attack_area = select_figure.get_node("attack")
	#
	#var walk_gex = walk_area.get_overlapping_areas()
	#var attack_gex = attack_area.get_overlapping_areas()
	#print(walk_gex)
	#print(attack_gex)
	#for gex_w in walk_gex:
		#if !check_gex_group(gex_w) and gex_w.has_node("Gex"):
			#gex_w.get_node("Gex").set_surface_override_material(0, walk_material)
			#print("green_walk")
	#for gex_a in attack_gex:
		#if check_gex_group(gex_a) and !gex_a.is_in_group(C.USERNAME) and gex_a.has_node("Gex"):
			#gex_a.get_node("Gex").set_surface_override_material(0, attack_material)
			#print("red_walk")
#
#
#func check_gex_group(gex):
	#print(players_group)
	#for group in players_group:
		#if gex.is_in_group(group):
			#return true
	#return false
#

@rpc("authority", "call_local", "reliable")
func player_turn():
	if active_player.size() == 0:
		return
	
	var player = active_player[0] 
	$USER/UI/player_turn_go.text = players_user[player]["username"] + " заебал, ходи!"
	



func random_first_turn():
	if active_player.size() == 0:
		return
	var first = active_player.pick_random()
	active_player.erase(first)
	active_player.insert(0, first)


func kazna_nx(nx):
	if nx == "entered":
		kazna_ico_select += 1
		$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	elif nx == "exited":
		kazna_ico_select -= 1
		$USER/UI/Kazna_b/Kazna.texture = kazna_ico[kazna_ico_select]
	elif nx == "open":
		$USER/UI/Kazna_W.popup()

func close_window(window):
	match window:
		"info" : $USER/UI/Info_W.hide()
		"kazna" : $USER/UI/Kazna_W.hide()


func magaz_connect():
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

func buy_figura(figura):
	$USER/UI/Kazna_W.hide()
	print(figura)




























































#
