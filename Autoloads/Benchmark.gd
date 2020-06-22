extends Node

var points : int = 0
var stages : PoolIntArray = [0,0,0,0,0,0]

var benchmarks_waits_to_be_shown : bool = false

func clear_results():
	for i in range(stages.size()):
		stages[i] = 0
	points = 0
