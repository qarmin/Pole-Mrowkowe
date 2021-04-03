extends Node

# Minusowe oznaczają, że nie można na nie wchodzić
# Muszą być to wartości następujące po sobie - -1,0,1,2 etc.
enum TYPES_OF_HEX { TYPE_MIN = -3, PUDDLE = -2, STONES = -1,  NORMAL = 0 , FIELD = 1, TREE = 2, TYPE_MAX = 3 }

var fields : Array = []

func _ready() -> void:
	var default : Dictionary = {"wood": 0, "water": 0, "gold": 0, "food": 0,}
	
	add_field({"name": "puddle", "type" : TYPES_OF_HEX.PUDDLE , "production" : default})
	add_field({"name": "stones", "type" : TYPES_OF_HEX.STONES ,"production" :default})
	add_field({"name": "normal", "type" : TYPES_OF_HEX.NORMAL ,"production" :{"wood": 10, "water": 10, "gold": 5, "food": 10,}})
	add_field({"name": "field", "type" : TYPES_OF_HEX.FIELD ,"production" :{"wood": 5, "water": 15, "gold": 2, "food": 20,}})
	add_field({"name": "tree", "type" : TYPES_OF_HEX.TREE ,"production" :{"wood": 30, "water": 15, "gold": 3, "food": 0,}})
	
func add_field(data : Dictionary) -> void:
	assert(data["production"].size() == Resources.resources.size())
	assert(data["production"].has_all(Resources.resources))
	
	validate_type(data["type"])
	
	fields.append(data)
	
func get_field_production(type : int) -> Dictionary:
	validate_type(type)
	return {}

func validate_type(type : int) -> void:
	assert(type > TYPES_OF_HEX.TYPE_MIN && type < TYPES_OF_HEX.TYPE_MAX)
