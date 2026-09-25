extends Node

var maxWind := 0.2
var wind := maxWind

var env
var world_env
@export var sanches_light: Light3D
@export var night_light: Light3D
@export var sky_mesh: MeshInstance3D

@export var transition_duration: float = 5.0
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_SINE

var _current_tween: Tween
var _sky_material: StandardMaterial3D



@export var Day = {
	"Fog_Color" : Color(0.824, 0.839, 0.867, 1.0),
	"Fog_Energy" : 0.7,
	"Fog_Density" : 0.1,
	"Sanches_Color" : Color(0.906, 0.894, 0.776, 1.0),
	"Sanches_Energy" : 8.0,
	"Night_Color" : Color(0.463, 0.757, 0.984, 1.0),
	"Night_Energy" : 1.0,
	"Sky_Color" : Color(0.427, 0.749, 0.702, 1.0),
	}

@export var evening = {
	"Fog_Color" : Color(0.922, 0.541, 0.502, 1.0),
	"Fog_Energy" : 0.7,
	"Fog_Density" : 0.1,
	"Sanches_Color" : Color(0.831, 0.337, 0.082, 1.0),
	"Sanches_Energy" : 6.0,
	"Night_Color" : Color(0.463, 0.757, 0.984, 1.0),
	"Night_Energy" : 5.0,
	"Sky_Color" : Color(0.882, 0.416, 0.357, 1.0),
	}

@export var night = {
	"Fog_Color" : Color(0.373, 0.392, 0.451, 1.0),
	"Fog_Energy" : 0.7,
	"Fog_Density" : 0.1,
	"Sanches_Color" : Color(0.8, 0.98, 0.922, 1.0),
	"Sanches_Energy" : 1.85,
	"Night_Color" : Color(0.059, 0.424, 0.643, 1.0),
	"Night_Energy" : 6.0,
	"Sky_Color" : Color(0.055, 0.133, 0.224, 1.0),
	}

@export var morning = {
	"Fog_Color" : Color(0.851, 0.784, 0.671, 1.0),
	"Fog_Energy" : 0.7,
	"Fog_Density" : 0.1,
	"Sanches_Color" : Color(0.898, 0.792, 0.42, 1.0),
	"Sanches_Energy" : 8.0,
	"Night_Color" : Color(0.463, 0.757, 0.984, 1.0),
	"Night_Energy" : 2.0,
	"Sky_Color" : Color(0.835, 0.694, 0.494, 1.0),
	}



func _ready() -> void:
	env = preload("res://scn/game_scn/main_environment.tres")
	if sky_mesh and sky_mesh.mesh:
		_sky_material = sky_mesh.mesh.surface_get_material(0)
	await get_tree().create_timer(1).timeout
	buttons_con()

func transition_to(target: Dictionary, duration: float = -1.0) -> void:
	if duration < 0:
		duration = transition_duration
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.set_ease(ease_type)
	_current_tween.set_trans(trans_type)
	
	_current_tween.tween_property(env, "fog_light_color", target["Fog_Color"], duration)
	_current_tween.tween_property(env, "fog_light_energy", target["Fog_Energy"], duration)
	_current_tween.tween_property(env, "fog_density", target["Fog_Density"], duration)
	_current_tween.tween_property(sanches_light, "light_color", target["Sanches_Color"], duration)
	_current_tween.tween_property(sanches_light, "light_energy", target["Sanches_Energy"], duration)
	_current_tween.tween_property(night_light, "light_color", target["Night_Color"], duration)
	_current_tween.tween_property(night_light, "light_energy", target["Night_Energy"], duration)
	if _sky_material:
		_current_tween.tween_property(_sky_material, "albedo_color", target["Sky_Color"], duration)


func to_day(duration: float = -1.0) -> void:
	transition_to(Day, duration)

func to_evening(duration: float = -1.0) -> void:
	transition_to(evening, duration)

func to_night(duration: float = -1.0) -> void:
	transition_to(night, duration)

func to_morning(duration: float = -1.0) -> void:
	transition_to(morning, duration)


func start_full_cycle(step_duration: float = 20.0) -> void:
	to_day(step_duration)
	await get_tree().create_timer(step_duration).timeout
	to_evening(step_duration)
	await get_tree().create_timer(step_duration).timeout
	to_night(step_duration)
	await get_tree().create_timer(step_duration).timeout
	to_morning(step_duration)



func buttons_con():
	$Button.pressed.connect(func(): to_day(8))
	$Button2.pressed.connect(func(): to_evening(8))
	$Button3.pressed.connect(func(): to_night(8))
	$Button4.pressed.connect(func(): to_morning(8))
