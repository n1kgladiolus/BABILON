extends MeshInstance3D

var fromz = -12
var toz = 12

var x = 0
var z = 1
var xStep = 0
var rf = 0
var rt = 2
var scene = preload("res://san_clouds/Resourses/cloud.tscn")
@onready var game: Node3D = $"../../.."


func _on_timer_timeout() -> void:
	for i in range(5):
		await get_tree().process_frame
		global_position.z += game.wind

func _ready() -> void:
	$"../Timer".timeout.connect(_on_timer_timeout)
	await get_tree().process_frame
	material_override = load("res://san_clouds/Resourses/clouds.tres")
	CloudSpawn()
	
	while global_position.z < fromz + (z*0.6) - game.wind*10:
		await get_tree().process_frame
	var obj = scene.instantiate()
	$"..".add_child.call_deferred(obj)
	
	while global_position.z < toz:
		await get_tree().process_frame
		
	if game.wind == 0.2:
		game.wind = 0.01
		
	queue_free()

func CloudSpawn():
	z = randf_range(1, 3)
	for i in range(20):
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		
		xStep = randf_range(1, 2)
		
		var P11 = Vector3(0+x, 0, 0)
		var P12 = Vector3(1+x+xStep, 0, 0)
		var P13 = Vector3(0+x, 0, 1*z)
		var P14 = Vector3(1+x+xStep, 0, 1*z)
		
		var P21 = Vector3(0.25+x+(xStep/4), 0.5*randf_range(1, 2), 0.25)
		var P22 = Vector3(0.75+x+(xStep/2), 0.5*randf_range(1, 2), 0.25)
		var P23 = Vector3(0.25+x+(xStep/4), 0.5*randf_range(1, 2), 0.75*z)
		var P24 = Vector3(0.75+x+(xStep/2), 0.5*randf_range(1, 2), 0.75*z)
		
		var uv11 = Vector2(0*randi_range(rf, rt), 0*randi_range(rf, rt))
		var uv12 = Vector2(1*randi_range(rf, rt), 0*randi_range(rf, rt))
		var uv13 = Vector2(0*randi_range(rf, rt), 1*randi_range(rf, rt))
		var uv14 = Vector2(1*randi_range(rf, rt), 1*randi_range(rf, rt))
		var uv21 = Vector2(0.25*randi_range(rf, rt), 0.25*randi_range(rf, rt))
		var uv22 = Vector2(0.75*randi_range(rf, rt), 0.25*randi_range(rf, rt))
		var uv23 = Vector2(0.25*randi_range(rf, rt), 0.75*randi_range(rf, rt))
		var uv24 = Vector2(0.75*randi_range(rf, rt), 0.75*randi_range(rf, rt))
		
		#var PC = Vector3(0.5+x, 1, 0.5)
		
		# 1--------------------------
		mesh.surface_set_uv(uv11); mesh.surface_add_vertex(P11)
		mesh.surface_set_uv(uv12); mesh.surface_add_vertex(P12)
		mesh.surface_set_uv(uv21); mesh.surface_add_vertex(P21)
	
		mesh.surface_set_uv(uv22); mesh.surface_add_vertex(P22)
		mesh.surface_set_uv(uv21); mesh.surface_add_vertex(P21)
		mesh.surface_set_uv(uv12); mesh.surface_add_vertex(P12)
	
		# 2--------------------------
		mesh.surface_set_uv(uv23); mesh.surface_add_vertex(P23)
		mesh.surface_set_uv(uv14); mesh.surface_add_vertex(P14)
		mesh.surface_set_uv(uv13); mesh.surface_add_vertex(P13)
	
		mesh.surface_set_uv(uv14); mesh.surface_add_vertex(P14)
		mesh.surface_set_uv(uv23); mesh.surface_add_vertex(P23)
		mesh.surface_set_uv(uv24); mesh.surface_add_vertex(P24)
	
		# 3--------------------------
		mesh.surface_set_uv(uv21); mesh.surface_add_vertex(P21)
		mesh.surface_set_uv(uv13); mesh.surface_add_vertex(P13)
		mesh.surface_set_uv(uv11); mesh.surface_add_vertex(P11)
	
		mesh.surface_set_uv(uv21); mesh.surface_add_vertex(P21)
		mesh.surface_set_uv(uv23); mesh.surface_add_vertex(P23)
		mesh.surface_set_uv(uv13); mesh.surface_add_vertex(P13)
	
		# 4--------------------------
		mesh.surface_set_uv(uv12); mesh.surface_add_vertex(P12)
		mesh.surface_set_uv(uv14); mesh.surface_add_vertex(P14)
		mesh.surface_set_uv(uv22); mesh.surface_add_vertex(P22)
	
		mesh.surface_set_uv(uv14); mesh.surface_add_vertex(P14)
		mesh.surface_set_uv(uv24); mesh.surface_add_vertex(P24)
		mesh.surface_set_uv(uv22); mesh.surface_add_vertex(P22)
	
		# С1-------------------------
		mesh.surface_set_uv(uv21); mesh.surface_add_vertex(P21)
		mesh.surface_set_uv(uv22); mesh.surface_add_vertex(P22)
		mesh.surface_set_uv(uv23); mesh.surface_add_vertex(P23)
	
		# С2-------------------------
		mesh.surface_set_uv(uv22); mesh.surface_add_vertex(P22)
		mesh.surface_set_uv(uv24); mesh.surface_add_vertex(P24)
		mesh.surface_set_uv(uv23); mesh.surface_add_vertex(P23)
		
		mesh.surface_end()
		x+=1+xStep
