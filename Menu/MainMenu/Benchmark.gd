extends Button

signal benchmark_menu_show

func _on_Benchmark_pressed() -> void:
	print("Przechodzę do menu benchmarku")
	if get_signal_connection_list("benchmark_menu_show").size() == 0:
		print_stack()
		printerr("Sygnał benchmark_menu_show nie jest podłączony do żadnej funkcji")
		
	emit_signal("benchmark_menu_show")
