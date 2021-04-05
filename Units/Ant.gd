extends Spatial

class_name AntBase

signal ant_clicked

var owner_id: int = -1  # no_owner for now


func _on_StaticBody_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT && event.is_pressed():
#			add_child(load("res://Overlay/UnitOverlay.tscn").instance())
			if get_signal_connection_list("ant_clicked").size() == 0:
				print_stack()
				printerr("Sygnał ant_clicked nie jest podłączony do żadnej funkcji")
#				return
			emit_signal("ant_clicked", self)
