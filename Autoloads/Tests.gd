extends Node

const PRINT_TESTS : bool = true

func _ready() -> void:
	Vector2i_test()

func Vector2i_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test Vector2i")
	var vec_1 : Vector2i = Vector2i.new(1,3)
	var vec_2 : Vector2i = Vector2i.new(125,13)
	var vec_3 : Vector2i = Vector2i.new(42,25)
	var vec_4 : Vector2i = Vector2i.new(25,3)
	
	var array : Array = []
	
	array.append(Vector2i.new(1,3))
	array.append(Vector2i.new(2,3))
	array.append(Vector2i.new(1,100))
	array.append(Vector2i.new(125,12))
	
	
	assert(Vector2i.is_in_array(array,vec_1))
	assert(!Vector2i.is_in_array(array,vec_2))
	assert(!Vector2i.is_in_array(array,vec_3))
	assert(!Vector2i.is_in_array(array,vec_4))
	assert(Vector2i.is_in_array(array,Vector2i.new(1,3)))
	assert(!Vector2i.is_in_array(array,Vector2i.new(125,13)))
	assert(!Vector2i.is_in_array(array,Vector2i.new(42,25)))
	assert(!Vector2i.is_in_array(array,Vector2i.new(25,3)))
