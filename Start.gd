extends Spatial

func _ready():
	assert(get_tree().change_scene("res://Menu/MenuCommon/MenuCommon.tscn") == OK)
