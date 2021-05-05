extends TextureRect

signal try_to_end_turn_clicked


func _on_Round_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# TODO może dodać to tylko na puszczenie przycisku a nie jego
		if event.get_button_index() == BUTTON_LEFT && event.is_pressed():
			if get_signal_connection_list("try_to_end_turn_clicked").size() == 0:
				print_stack()
				printerr("Sygnał try_to_end_turn_clicked nie jest podłączony do żadnej funkcji")
#				return
			emit_signal("try_to_end_turn_clicked")
