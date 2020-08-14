extends Spatial


func _ready():
	if get_tree().change_scene("res://Menu/Menu/Menu.tscn") != OK:
		assert(false)
