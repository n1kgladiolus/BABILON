extends Node3D

func _ready() -> void:
	#$D12.dice(10, $DiceSpawn.position, $DiceSpawn.rotation)
	
	for i in range(12):
		$D12.dice(i+1, $DiceSpawn.position, $DiceSpawn.rotation)
		await get_tree().create_timer(5.0).timeout
	for i in range(12):
		$D12.dice(12-i, $DiceSpawn.position, $DiceSpawn.rotation)
		await get_tree().create_timer(5.0).timeout
