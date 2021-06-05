extends Spatial

## TODO Pozamieniać wszystie res:// na user:// gdzie tylko to możliwe


func _ready():
	assert(get_tree().change_scene("res://Menu/Menu/Menu.tscn") == OK)
