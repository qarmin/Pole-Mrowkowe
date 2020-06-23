extends Control


func show_benchmarks() -> void:
	
#	find_node("WarningStart").set_text("Average " + str(Benchmark.points))
#
#	var low_points = Benchmark.stages_frames[0] + Benchmark.stages_frames[1] + Benchmark.stages_frames[2]
#	find_node("Low").set_text(
#		"LOW GRAPHICS(" + str(low_points)  +")\n"+
#		"3x3 MAP - " + str(Benchmark.stages_frames[0]) + "\n"+
#		"10x10 MAP - " + str(Benchmark.stages_frames[1]) + "\n"+
#		"30x30 MAP - " + str(Benchmark.stages_frames[2])
#	)
#	var high_points = Benchmark.stages_frames[3] + Benchmark.stages_frames[4] + Benchmark.stages_frames[5]
#	find_node("High").set_text(
#		"HIGH GRAPHICS(" + str(high_points)  +")\n"+
#		"3x3 MAP - " + str(Benchmark.stages_frames[3]) + "\n"+
#		"10x10 MAP - " + str(Benchmark.stages_frames[4]) + "\n"+
#		"30x30 MAP - " + str(Benchmark.stages_frames[5])
#	)
	
	find_node("WarningStart").set_text("Average - " + str(stepify(Benchmark.points / 60.0,0.1)) + " fps")
	
	var low_points = Benchmark.stages_frames[0] + Benchmark.stages_frames[1] + Benchmark.stages_frames[2]
	find_node("Low").set_text(
		"LOW GRAPHICS - " + str(stepify(low_points / 30.0,0.1))  +" fps\n"+
		"3x3 MAP - " + str(stepify(Benchmark.stages_frames[0] / 10.0,0.1)) + " fps\n"+
		"10x10 MAP - " + str(stepify(Benchmark.stages_frames[1] / 10.0,0.1)) + " fps\n"+
		"30x30 MAP - " + str(stepify(Benchmark.stages_frames[2] / 10.0,0.1)) + " fps"
	)
	var high_points = Benchmark.stages_frames[3] + Benchmark.stages_frames[4] + Benchmark.stages_frames[5]
	find_node("High").set_text(
		"HIGH GRAPHICS - " + str(stepify(high_points / 30.0,0.1))  +" fps\n"+
		"3x3 MAP - " + str(stepify(Benchmark.stages_frames[3] / 10.0,0.1)) + " fps\n"+
		"10x10 MAP - " + str(stepify(Benchmark.stages_frames[4] / 10.0,0.1)) + " fps\n"+
		"30x30 MAP - " + str(stepify(Benchmark.stages_frames[5] / 10.0,0.1)) + " fps"
	)
