extends Button

signal back_to_menu_campaign

func _on_BackToMenuCampaign_pressed():
	print("Wracam do menu kampanii")
	if get_signal_connection_list("back_to_menu_campaign").size() == 0:
		print_stack()
		printerr("Sygnał back_to_menu_campaign nie jest podłączony do żadnej funkcji")

	emit_signal("back_to_menu_campaign")
