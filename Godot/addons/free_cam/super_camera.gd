extends Node3D

@onready var cam := $Pivot1/Pivot2/Camera3D
var direction := Vector3.ZERO
var speed := 5
var sens := 0.001

func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	activate(true)

func activate(isActive: bool) -> void:
	if isActive:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	cam.current = isActive

func _input(event):
	if event is InputEventMouseMotion:
		$Pivot1.rotate_y(-event.relative.x*sens)
		$Pivot1/Pivot2.rotate_x(-event.relative.y*sens)

func _physics_process(delta):
	direction = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direction -= cam.global_transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += cam.global_transform.basis.z
	if Input.is_key_pressed(KEY_A):
		direction -= cam.global_transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += cam.global_transform.basis.x

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	global_position += direction * speed * delta
