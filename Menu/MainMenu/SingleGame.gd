extends Button

signal skirmish_menu_show


func _on_Single_Game_pressed() -> void:
	print("Przechodzę do menu pojedynku")
	if get_signal_connection_list("skirmish_menu_show").size() == 0:
		print_stack()
		printerr("Sygnał skirmish_menu_show nie jest podłączony do żadnej funkcji")

	emit_signal("skirmish_menu_show")
