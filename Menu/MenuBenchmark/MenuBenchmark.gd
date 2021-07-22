extends Control

var MAX_FPS: float = 60.0
const GRAPH_SIZE_X: float = 2048.0
const GRAPH_SIZE_Y: float = 512.0


func show_benchmarks() -> void:
	var x_offset: float = GRAPH_SIZE_X / Benchmark.STAGES
	var step_y: float = 0

	# Wynik 99% - Usuwa ~1% zbyt dużych/małych wyników, póki co nie potrzebuje bo raczej nie działa poprawnie
	for i in range(Benchmark.STAGES):
		if Benchmark.time_frame[i].size() < 10:  # Nie chcę zbyt dużo obcinać wyników
			continue

		for _j in range(Benchmark.time_frame[i].size() / 100 + 2):
			var smallest_index: int = -1
			var smallest_value: float = 10000

			for k in range(Benchmark.time_frame[i].size()):
				if Benchmark.time_frame[i][k] < smallest_value:
					smallest_index = k
					smallest_value = Benchmark.time_frame[i][k]
			Benchmark.time_frame[i].remove(smallest_index)

			var biggest_index: int = -1
			var biggest_value: float = -1

			for k in range(Benchmark.time_frame[i].size()):
				if Benchmark.time_frame[i][k] > biggest_value:
					biggest_index = k
					biggest_value = Benchmark.time_frame[i][k]
			Benchmark.time_frame[i].remove(biggest_index)

	# Zminiejsza ilość pomiarów na < 1000
	for i in range(Benchmark.STAGES):
		while Benchmark.time_frame[i].size() > 200:
			var temp_array: Array = []
			var current_index: int = 0
			while current_index + 1 < Benchmark.time_frame[i].size():
				temp_array.append((Benchmark.time_frame[i][current_index] + Benchmark.time_frame[i][current_index + 1]) / 2.0)
				current_index += 2
			Benchmark.time_frame[i] = temp_array

	# Ustala jaka najodpowidniejsza będzie dla grafu skala, póki co używam stałej
	for i in range(Benchmark.STAGES):
		if Benchmark.time_frame[i].size() > 0:
			if (GRAPH_SIZE_Y / max(1.0 / max(Benchmark.time_frame[i].min(), 0.001), MAX_FPS)) > step_y:
				MAX_FPS = max(1.0 / max(Benchmark.time_frame[i].min(), 0.001), MAX_FPS)
	step_y = GRAPH_SIZE_Y / MAX_FPS

	# Czyści wszystkie linie
	for i in range(Benchmark.STAGES):
		get_node("Viewport/FrameTime" + str(i + 1)).clear_points()

	# Uzupełnia wszystkie linie
	for i in range(Benchmark.STAGES):
		if Benchmark.time_frame[i].size() > 1:
			var new_line2D: Line2D = get_node("Viewport/FrameTime" + str(i + 1))

			var step_x: float = x_offset / (Benchmark.time_frame[i].size() - 1)

			if i > 0:  # Bierze ostatni wynik z poprzedniego diagramu tak aby nie było brzydkiego przeskoku w wykresie
				var old_line2D: Line2D = get_node("Viewport/FrameTime" + str(i))

				new_line2D.add_point(old_line2D.get_point_position(old_line2D.get_point_count() - 1))

			for j in range(0, Benchmark.time_frame[i].size()):
				if Benchmark.time_frame[i][j] < 1.0 / MAX_FPS:
					Benchmark.time_frame[i][j] = 1.0 / MAX_FPS
				new_line2D.add_point(Vector2(j * step_x + x_offset * i, 1.0 / Benchmark.time_frame[i][j] * step_y - 3))
	$TextureRect/VBoxContainer/Graph.set_texture($Viewport.get_texture())

	find_node("WarningStart").set_text("Average - " + str(snapped(Benchmark.average_fps, 0.1)) + " fps")

	assert(Benchmark.STAGES == 6)

	var low_points = (Benchmark.stages_frames_per_second[0] + Benchmark.stages_frames_per_second[1] + Benchmark.stages_frames_per_second[2]) / 3.0
	find_node("Low").set_text(
		(
			"LOW GRAPHICS - "
			+ str(snapped(low_points, 0.1))
			+ " fps\n"
			+ "3x3 MAP - "
			+ str(snapped(Benchmark.stages_frames_per_second[0], 0.1))
			+ " fps\n"
			+ "10x10 MAP - "
			+ str(snapped(Benchmark.stages_frames_per_second[1], 0.1))
			+ " fps\n"
			+ "30x30 MAP - "
			+ str(snapped(Benchmark.stages_frames_per_second[2], 0.1))
			+ " fps"
		)
	)
	var high_points = (Benchmark.stages_frames_per_second[3] + Benchmark.stages_frames_per_second[4] + Benchmark.stages_frames_per_second[5]) / 3.0
	find_node("High").set_text(
		(
			"HIGH GRAPHICS - "
			+ str(snapped(high_points, 0.1))
			+ " fps\n"
			+ "3x3 MAP - "
			+ str(snapped(Benchmark.stages_frames_per_second[3], 0.1))
			+ " fps\n"
			+ "10x10 MAP - "
			+ str(snapped(Benchmark.stages_frames_per_second[4], 0.1))
			+ " fps\n"
			+ "30x30 MAP - "
			+ str(snapped(Benchmark.stages_frames_per_second[5], 0.1))
			+ " fps"
		)
	)
