extends RigidBody3D

var myPos
var myDir
var colDir

@onready var texture = $Pivot/MeshInstance3D
@onready var texturePivot = $Pivot
@onready var collision = $CollisionShape3D

var values = [
	Vector3(180.0, 0, 0),#1
	Vector3(116.6, 72.0, 0),#2
	Vector3(116.6, 144.0, 0),#3
	Vector3(116.6, 0, 0),#4
	Vector3(116.6, 216.0, 0),#5
	Vector3(116.6, 288.0, 0),#6
	Vector3(296.0, 288.0, 0),#7
	Vector3(296.0, 216.0, 0),#8
	Vector3(296.6, 0, 0),#9
	Vector3(296.6, 144.0, 0),#10
	Vector3(296.6, 72.0, 0),#11
	Vector3(0, 0, 0)#12
]

func _ready() -> void:
	myPos = global_position
	myDir = global_rotation_degrees
	colDir = collision.global_rotation_degrees
	
	visible = false

func dice(value: int, pos: Vector3, dir: Vector3):
	texturePivot.rotation_degrees.x = values[value-1].x
	texture.rotation_degrees.y = values[value-1].y
	texturePivot.rotation_degrees.z = values[value-1].z
	
	global_position = pos
	global_rotation = dir
	
	freeze = false
	visible = true
	
	if value >= 6 and value != 12:
		collision.global_rotation_degrees = values[value-1]
		apply_impulse(transform.basis.y * 3)
		apply_impulse(-transform.basis.z * 2.5)
		apply_torque(Vector3(1, 0, 0) * -25)
		apply_torque(Vector3(0, 0, 1) * -35)
	else:
		apply_impulse(transform.basis.y * 3)
		apply_impulse(-transform.basis.z * 3)
		apply_torque(Vector3(1, 0, 0) * -25)
		apply_torque(Vector3(0, 0, 1) * 37)
	
	
	await get_tree().create_timer(5.0).timeout
	
	global_rotation_degrees = myDir
	global_position = myPos
	collision.global_rotation_degrees = colDir
	freeze = true
	visible = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
