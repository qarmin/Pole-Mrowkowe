extends Control


func show_benchmarks() -> void:
	
	find_node("WarningStart").set_text("All points " + str(Benchmark.points))
	
	var low_points = Benchmark.stages[0] + Benchmark.stages[1] + Benchmark.stages[2]
	find_node("Low").set_text(
		"LOW GRAPHICS(" + str(low_points)  +")\n"+
		"3x3 MAP - " + str(Benchmark.stages[0]) + "\n"+
		"10x10 MAP - " + str(Benchmark.stages[1]) + "\n"+
		"30x30 MAP - " + str(Benchmark.stages[2])
	)
	var high_points = Benchmark.stages[3] + Benchmark.stages[4] + Benchmark.stages[5]
	find_node("High").set_text(
		"HIGH GRAPHICS(" + str(high_points)  +")\n"+
		"3x3 MAP - " + str(Benchmark.stages[3]) + "\n"+
		"10x10 MAP - " + str(Benchmark.stages[4]) + "\n"+
		"30x30 MAP - " + str(Benchmark.stages[5])
	)
