extends TextureButton

signal new_campaign


func _on_CreateNewGame_pressed() -> void:
	print("Tworzę nową kampanię")
	if get_signal_connection_list("new_campaign").size() == 0:
		print_stack()
		printerr("Sygnał new_campaign nie jest podłączony do żadnej funkcji")

	emit_signal("new_campaign")
