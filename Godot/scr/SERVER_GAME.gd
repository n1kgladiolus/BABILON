extends Node

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func send_all(data: Array):
	if R.NET.has_node("net_game"):
		R.NET.get_node("net_game").from_server.rpc(data)

func send_id(id, data: Array):
	if R.NET.has_node("net_game"):
		R.NET.get_node("net_game").from_server.rpc_id(id, data)

func command(sender_id: int, data: Array):
	pass
