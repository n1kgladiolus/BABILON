extends MeshInstance3D

@onready var radius = mesh.radius * 0.9
var starScene := preload("res://addons/Sky/star.tscn")
var material := preload("res://addons/Sky/star2.tres")
var starMaterial := preload("res://addons/Sky/star.tres")
var amount = 15

func galaxySpawn():
	var galaxy := []
	var angle := randf_range(0, TAU)
	var star := starScene.instantiate()
	star.position = position + Vector3(cos(angle), randf_range(0.1, 0.6), sin(angle)).normalized() * radius
	add_child(star)
	star.look_at(global_position, Vector3.UP)
	star.get_child(0).material_override = starMaterial.duplicate()
	galaxy.append(star)
	
	for i in range(randi_range(2, 5)):
		angle += randf_range(1, PI)
		
		star = starScene.instantiate()
		galaxy[i].add_child(star)
		star.global_position = galaxy[i].global_position + Vector3(cos(angle), randf_range(-1, 1), sin(angle)).normalized()
		star.look_at(Vector3(0, 0, 0), Vector3.UP)
		star.get_child(0).material_override = starMaterial.duplicate()
		galaxy.append(star)
		draw_line(galaxy[i].global_position, galaxy[-1].global_position, 0.025)
	
	while true:
		await get_tree().create_timer(randf_range(0.1, 2)).timeout
		for i in range(galaxy.size()):
			galaxy[i].get_child(0).material_override.emission_energy_multiplier = clamp(galaxy[i].get_child(0).material_override.emission_energy_multiplier-randf_range(-3.5, 3.5), 1, 16)

func _ready() -> void:
	for i in range(amount):
		await get_tree().physics_frame
		galaxySpawn()

func draw_line(from: Vector3, to: Vector3, thickness: float = 0.05):
	var dir = (to - from).normalized()
	var distance = from.distance_to(to)
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = thickness
	mesh.bottom_radius = thickness
	mesh.height = distance
	
	var instance = MeshInstance3D.new()
	instance.mesh = mesh
	instance.cast_shadow = false
	instance.position = (from + to) / 2
	
	var basis = Basis.looking_at(dir, Vector3.UP)
	basis = basis * Basis(Vector3.RIGHT, -PI/2)
	
	instance.transform.basis = basis
	instance.material_override = material
	add_child(instance)

func _process(delta: float) -> void:
	rotate_y(0.00001)
	
