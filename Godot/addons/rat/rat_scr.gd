extends Node

func Move(arr: Array, myGex: Node3D) -> Node3D:
	var best
	var bestLvl = -INF
	var bestAtt = INF
	var bestHard = INF
	
	var myLvL = getLvL(myGex.get_parent().name)
	
	for gex in arr:
		if gex.is_in_group("centr"):
			return gex
		var lvl = getLvL(gex.get_parent().name)
		var hard = 0
		if gex.is_in_group("slon") or gex.is_in_group("slon_fan"):
			hard = 2
		if myLvL < lvl:
			hard += 1
		if (bestLvl < lvl) or ((bestLvl == lvl) and (bestAtt >= gex.get_meta("attack")) and (bestHard <= hard)):
			best = gex
			bestLvl = lvl
			bestAtt = gex.get_meta("attack")
			bestHard = hard
	
	return best

func getLvL(name: String) -> int:
	match name:
		"A": return 1
		"B": return 2
		"C": return 3
	return 0











#
