extends Button

signal campaign_menu_show

func _on_Campaign_pressed() -> void:
	print("Przechodzę do menu kampanii")
	if get_signal_connection_list("campaign_menu_show").size() == 0:
		print_stack()
		printerr("Sygnał campaign_menu_show nie jest podłączony do żadnej funkcji")
		
	emit_signal("campaign_menu_show")
