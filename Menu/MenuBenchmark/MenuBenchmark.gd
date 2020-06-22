extends Control


func show_benchmarks() -> void:	
	
	find_node("WarningStart").hide()
	
	var low_node : Node = find_node("Low")
	low_node.set_text(
		"LOW GRAPHICS\n"+
		"3x3 MAP - " + str(Benchmark.stages[0]) + "\n"+
		"10x10 MAP - " + str(Benchmark.stages[1]) + "\n"+
		"30x30 MAP - " + str(Benchmark.stages[2])
	)
	
	var high_node : Node = find_node("High")
	high_node.set_text(
		"HIGH GRAPHICS\n"+
		"3x3 MAP - " + str(Benchmark.stages[3]) + "\n"+
		"10x10 MAP - " + str(Benchmark.stages[4]) + "\n"+
		"30x30 MAP - " + str(Benchmark.stages[5])
	)
