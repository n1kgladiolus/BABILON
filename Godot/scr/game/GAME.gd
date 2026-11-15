extends Node

var command_list: Dictionary = {
	
	}


var NET
var RUN



func _ready() -> void:
	NET = R.NET
	if has_node("/root/RUN"):
		RUN = get_node("/root/RUN")

func _process(delta: float) -> void:
	pass
