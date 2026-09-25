extends Node3D
@export var cam_settings := [0, 15, 0.15, null, null]
@export var cam_block = true


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if cam_block:
		return
	$piv_1/piv_2.rotation_degrees.x += (cam_settings[0] - $piv_1/piv_2.rotation_degrees.x)/12
	if Input.is_action_pressed("A"):
		$piv_1.rotation_degrees.y -= 0.55
	elif Input.is_action_pressed("D"):
		$piv_1.rotation_degrees.y += 0.55

func _input(event):
	if cam_block:
		return
	if event.is_action_pressed("W"):
		cam_settings[0] = -40
		_cam_down()
	elif event.is_action_released("W"):
		cam_settings[0] = 0
		_cam_up()
	elif event.is_action_pressed("RMB"):
		cam_settings[0] = -40
		_cam_down()
	elif event.is_action_released("RMB"):
		cam_settings[0] = 0
		_cam_up()


func _cam_down():
	if cam_settings[4]:
		cam_settings[4].kill()
	cam_settings[4] = create_tween()
	cam_settings[4].tween_property($piv_1, "global_position:y", -0.3, 0.3)

func _cam_up():
	if cam_settings[4]:
		cam_settings[4].kill()
	cam_settings[4] = create_tween()
	cam_settings[4].tween_property($piv_1, "global_position:y", 0.0, 0.3)
