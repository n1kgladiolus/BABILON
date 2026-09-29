extends Node

var NET
var RUN


func _ready() -> void:
	NET = R.NET
	RUN = get_node("/root/RUN")
	
	$World.get_node("environment").to_night(0)
	
	
	
	$log_in.pressed.connect(func():
		NET.get_node("net_game").setup("client", {"url": "ws://188.168.138.144:6769"})
		NET.get_node("net_voice").setup("client", {"url": "ws://188.168.138.144:6770"})
		)
	$log_out.pressed.connect(func():
		NET.get_node("net_game").disconnect_game()
		NET.get_node("net_voice").disconnect_voice()
		)
	

func _process(delta: float) -> void:
	pass
