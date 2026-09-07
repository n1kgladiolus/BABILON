extends Node3D

var isStop := false
var isTrueStop := false
var inertia := Vector3.ZERO
var zoo := ["res://king/gerb/Bear.png", "res://king/gerb/Bull.png", "res://king/gerb/Dragon.png", "res://king/gerb/Eagle.png", "res://king/gerb/Elephant.png", "res://king/gerb/Lion.png"]
var time := 0.0
var target

func _ready() -> void:
	Roll(randi_range(0,5))


func Roll(morda: int) -> void:
	visible = true
	target = morda
	
	$monetochka.apply_torque(Vector3(1, 0, 0) * 600)
	$monetochka.apply_central_impulse(Vector3(0, 2, 0))
	await get_tree().process_frame
	inertia = $monetochka.angular_velocity
	
	await get_tree().create_timer(2.5).timeout
	isStop = true

func  _physics_process(delta: float) -> void:
	time += delta
	
	if $monetochka.position.y >= -1.3:
		$monetochka.linear_velocity *= 0.98
	
	if isTrueStop:
		$monetochka.angular_velocity *= 0.955
	elif inertia != Vector3.ZERO:
		$monetochka.angular_velocity = inertia

func _on_trigger_area_entered(area: Area3D) -> void:
	if !isStop:
		area.get_parent().texture = load(zoo.pick_random())
	else:
		area.get_parent().texture = load(zoo[target])
		await get_tree().process_frame
		isTrueStop = true
