extends Button



func _on_StartBenchmark_pressed() -> void:
	if get_tree().change_scene("res://Benchmark/Benchmark.tscn") != OK:
		assert(false)
