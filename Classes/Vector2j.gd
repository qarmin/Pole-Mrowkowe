class_name Vector2j

var x : int = 0
var y : int = 0


func _init(var p_x : int, var p_y : int) -> void:
	x = p_x
	y = p_y
	
static func is_in_array(var array : Array, var vector) -> bool:# : Vector2j) -> bool: #BUG
	assert(vector.x >= 0 && vector.y >= 0)
	for i in array:
		if i.x == vector.x:
			if i.y == vector.y:
				return true
	return false
	
static func is_in_array_reversed(var array : Array, var vector) -> bool:# : Vector2j) -> bool: #BUG
	assert(vector.x >= 0 && vector.y >= 0)
	for i in array:
		if i.x == vector.y:
			if i.y == vector.x:
				return true
	return false

