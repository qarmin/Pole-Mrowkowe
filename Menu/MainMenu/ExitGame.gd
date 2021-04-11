extends Button

signal exit_game


func _ready() -> void:
	pass


func _on_Exit_Game_pressed() -> void:
	print("Wyłączam grę")
	if get_signal_connection_list("exit_game").size() == 0:
		print_stack()
		printerr("Sygnał exit_game nie jest podłączony do żadnej funkcji")

	emit_signal("exit_game")
