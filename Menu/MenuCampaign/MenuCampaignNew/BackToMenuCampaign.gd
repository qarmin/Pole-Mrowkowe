extends Button

signal back_to_menu


func _on_BackToMenuCampaign_pressed():
	print("Wracam do menu głównego")
	if get_signal_connection_list("back_to_menu").size() == 0:
		print_stack()
		printerr("Sygnał back_to_menu nie jest podłączony do żadnej funkcji")

	emit_signal("back_to_menu")
