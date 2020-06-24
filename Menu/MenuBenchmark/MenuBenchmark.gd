extends Control


func show_benchmarks() -> void:
#	if Benchmark.time_frame.size() > 5 && Benchmark.points > 5:
#		var step_x : float = 2048.0 / (Benchmark.time_frame.size() - 1) 
#		var step_y : float = 512.0 / min(Benchmark.time_frame.max(), 0.2) # Najmniej 5 FPS
#
#		for i in range(1,Benchmark.time_frame.size()):
#			$Viewport/FrameTime.add_point(Vector2(i*step_x,Benchmark.time_frame[i] * step_y))
	var x_offset : float = 2048.0 / Benchmark.STAGES
	for i in range(Benchmark.STAGES):
		if Benchmark.time_frame[i].size() > 1:
			
			var new_line2D : Line2D = get_node("Viewport/FrameTime" + str(i+1))
				
			var step_x : float = x_offset / (Benchmark.time_frame[i].size() - 1) 
			var step_y : float = 512.0 / (1.0 / max(Benchmark.time_frame[i].min(), 1.0 / 120.0)) # Najwięcej 120 FPS
			
			if i > 0: # Bierze ostatni wynik z poprzedniego diagramu tak aby nie było brzydkiego przeskoku w wykresie
				var old_line2D : Line2D = get_node("Viewport/FrameTime" + str(i))
				
				new_line2D.add_point(old_line2D.get_point_position(old_line2D.get_point_count() - 1))
			
			for j in range(0,Benchmark.time_frame[i].size()):
				if Benchmark.time_frame[i][j] < 1/120.0:
					Benchmark.time_frame[i][j] = 1/119.0
				new_line2D.add_point(Vector2(j * step_x + x_offset * i, 1.0 / Benchmark.time_frame[i][j] * step_y))
	
	$TextureRect/VBoxContainer/Graph.set_texture($Viewport.get_texture())
	
	
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
