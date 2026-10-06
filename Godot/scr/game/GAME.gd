extends Node

var command_list: Dictionary = {
	
	}


var NET
var RUN



func _ready() -> void:
	NET = R.NET
	RUN = get_node("/root/RUN")

func _process(delta: float) -> void:
	pass
