extends Control


func _ready() -> void:
	$Buildings.hide()
	$Units.hide()
	pass

func update_current_player_text_color(player : int ) -> void:
	$CurrentPlayer/TextureRect.set_texture(load("res://Units/Outfit/SingleHexTEAM" + str(player + 1)+".png"))
	$CurrentPlayer/TextureRect/Label.set_text("Current Player: " + str(player))
