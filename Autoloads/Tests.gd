extends Node

const PRINT_TESTS : bool = false

func _ready() -> void:
	Vector2j_test()
	
	
	print("Wykonano wszystkie testy")

func Vector2j_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test Vector2j")
	var vec_1 : Vector2j = Vector2j.new(1,3)
	var vec_2 : Vector2j = Vector2j.new(125,13)
	var vec_3 : Vector2j = Vector2j.new(42,25)
	var vec_4 : Vector2j = Vector2j.new(25,3)
	var vec_5 : Vector2j = Vector2j.new(31,25)
	
	var array : Array = []
	
	array.append(Vector2j.new(1,3))
	array.append(Vector2j.new(2,3))
	array.append(Vector2j.new(1,100))
	array.append(Vector2j.new(125,12))
	array.append(Vector2j.new(25,31))
	
	assert(Vector2j.is_in_array(array,vec_1))
	assert(!Vector2j.is_in_array(array,vec_2))
	assert(!Vector2j.is_in_array(array,vec_3))
	assert(!Vector2j.is_in_array(array,vec_4))
	assert(Vector2j.is_in_array_reversed(array,vec_5))
	assert(Vector2j.is_in_array(array,Vector2j.new(1,3)))
	assert(!Vector2j.is_in_array(array,Vector2j.new(125,13)))
	assert(!Vector2j.is_in_array(array,Vector2j.new(42,25)))
	assert(!Vector2j.is_in_array(array,Vector2j.new(25,3)))
	assert(Vector2j.is_in_array_reversed(array,Vector2j.new(31,25)))
