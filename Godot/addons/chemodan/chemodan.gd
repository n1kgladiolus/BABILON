extends Node3D

var isOpen = false
var rot = 0

func _ready() -> void:
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
