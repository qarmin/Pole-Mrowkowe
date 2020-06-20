extends Control

func _ready() -> void:
	_back_to_menu()


func _exit_game() -> void:
	get_tree().quit()


func _back_to_menu() -> void:
	$MenuSkirmishNewGame.hide()
	$MenuOptions.hide()
	
	$MainMenu.show()


func _skirmish_menu_show() -> void:
	$MainMenu.hide()
	$MenuOptions.hide()
	
	$MenuSkirmishNewGame.show()
	
func _options_menu_show() -> void:
	$MainMenu.hide()
	$MenuSkirmishNewGame.hide()
	
	$MenuOptions.show()
