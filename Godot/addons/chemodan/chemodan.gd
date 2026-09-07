extends Node3D
var game_scene

var isClick = false
var isOpen = false
var rot = 0

func _ready() -> void:
	game_scene = get_tree().root.get_node("GAME")
	open()

func open():
	if isOpen == false:
		rot += 45
		isOpen = true
	else:
		rot -= 45
		isOpen = false

func _process(delta: float) -> void:
	if rot > 0:
		$Pivot.rotation_degrees += Vector3(0,0,1)
		rot -= 1
	elif rot < 0:
		$Pivot.rotation_degrees -= Vector3(0,0,1)
		rot += 1

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and isClick == false:
			isClick = true
			$krishkaDownOtd/Knopa/Obv.visible = false
			for i in range(19):
				await get_tree().process_frame
				$krishkaDownOtd/Knopa.global_position.y -= 0.005
			await get_tree().create_timer(0.5).timeout
			game_scene.nucklear_activate()
			open()

func _on_area_3d_mouse_entered() -> void:
	if isClick == false:
		$krishkaDownOtd/Knopa/Obv.visible = true

func _on_area_3d_mouse_exited() -> void:
	$krishkaDownOtd/Knopa/Obv.visible = false
