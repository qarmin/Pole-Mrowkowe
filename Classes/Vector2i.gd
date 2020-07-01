class_name Vector2i

var x : int = 0
var y : int = 0


func _init(var p_x : int, var p_y : int) -> void:
	x = p_x
	y = p_y

#func is_in_array(var array : Array) -> bool:
#	for i in array:
#		if i.x == x:
#			if i.y == y:
#				return true
#	return false

static func is_in_array(var array : Array, var vector) -> bool:# : Vector2i) -> bool: #BUG
	assert(vector.x >= 0 && vector.y >= 0)
	for i in array:
		if i.x == vector.x:
			if i.y == vector.y:
				return true
	return false
