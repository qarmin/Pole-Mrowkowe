extends Node3D

## TODO Pozamieniać wszystie res:// na user:// gdzie tylko to możliwe


func _ready():
	if get_tree().change_scene("res://Menu/Menu/Menu.tscn") != OK:
		assert(false)
