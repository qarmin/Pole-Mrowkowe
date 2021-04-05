extends MeshInstance
class_name SingleHex

signal hex_clicked

func _on_StaticBody_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT && event.is_pressed():
			if get_signal_connection_list("hex_clicked").size() == 0:
				print_stack()
				printerr("Sygnał hex_clicked nie jest podłączony do żadnej funkcji")
#				return
			emit_signal("hex_clicked", self)
