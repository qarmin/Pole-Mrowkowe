extends Spatial


func _ready():
	if get_tree().change_scene("res://Menu/MenuCommon/MenuCommon.tscn") != OK:
		assert(false)
