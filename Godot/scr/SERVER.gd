extends Node

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func send_all(data: Dictionary):
	if get_tree().root.has_node("net_main"):
		R.NET.get_node("net_main").from_server.rpc(data)

func send_id(id, data: Dictionary):
	if get_tree().root.has_node("net_main"):
		R.NET.get_node("net_main").from_server.rpc_id(id, data)

func command(sender_id: int, data: Dictionary):
	pass
