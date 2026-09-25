extends RigidBody3D

var myPos
@onready var texture = $MeshInstance3D
var values = [
	Vector3(0, -90, 0),
	Vector3(0, 0, 90),
	Vector3(0, 0, 0),
	Vector3(0, 180, 0),
	Vector3(0, 0, -90),
	Vector3(0, 90, 0)
]

func _ready() -> void:
	myPos = global_position
	visible = false

func dice(value: int, pos: Vector3, dir: Vector3):
	freeze = false
	visible = true
	
	texture.rotation_degrees = values[value-1]
	global_position = pos
	global_rotation = dir
	
	
	apply_impulse(transform.basis.y * 2)
	apply_impulse(-transform.basis.z * 4)
	apply_torque(Vector3(1, 0, 0) * -20)
	apply_torque(Vector3(0, 0, 1) * -20)
	
	
	await get_tree().create_timer(5.0).timeout
	
	visible = false
	global_position = myPos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
