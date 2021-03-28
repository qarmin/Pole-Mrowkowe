extends Node

# Minusowe oznaczają, że nie można na nie wchodzić
enum TYPES_OF_HEX { PUDDLE = -2, STONES = -1,  NORMAL = 0 , FIELD = 1, TREE =2 }


var fields : Array = []

func _ready() -> void:
	var default : Dictionary = {"wood": 0, "water": 0, "gold": 0, "food": 0,}
	
	add_field("puddle", default)
	add_field("stones", default)
	add_field("normal", {"wood": 10, "water": 10, "gold": 5, "food": 10,})
	add_field("field", {"wood": 5, "water": 15, "gold": 2, "food": 20,})
	add_field("tree", {"wood": 30, "water": 15, "gold": 3, "food": 0,})
	
	pass
	
func add_field(name : String, resources : Dictionary) -> void:
	assert(resources.size() == Resources.resources.size())
	assert(resources.has_all(Resources.resources))
	fields.append(resources)
