extends Control


func _ready() -> void:
	$Buildings.hide()
	$Units.hide()
	$MovingInfo.hide()
	pass


func update_current_player_text_color(player: int, human_player: bool) -> void:
	var type_of_player: String = ""
	if human_player:
		type_of_player = "(HUMAN)"
	else:
		type_of_player = "(CPU)"
	$CurrentPlayer/TextureRect.set_texture(load("res://Units/Outfit/SingleHexTEAM" + str(player + 1) + ".png"))
	$CurrentPlayer/TextureRect/Label.set_text("Current Player: " + str(player) + " " + type_of_player)
