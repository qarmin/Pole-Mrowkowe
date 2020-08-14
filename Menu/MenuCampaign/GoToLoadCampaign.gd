extends TextureButton

signal load_campaign


func _on_LoadCampaign_pressed() -> void:
	print("Ładuję kampanię")
	if get_signal_connection_list("load_campaign").size() == 0:
		print_stack()
		printerr("Sygnał load_campaign nie jest podłączony do żadnej funkcji")

	emit_signal("load_campaign")


func _on_TextureButton_focus_entered():
	
	pass # Replace with function body.


func _on_TextureButton_focus_exited():
	pass # Replace with function body.
