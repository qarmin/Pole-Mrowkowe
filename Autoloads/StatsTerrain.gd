extends Node

## TODO, to w ogłole będzie potrzebne?

# Minusowe oznaczają, że nie można na nie wchodzić
# Muszą być to wartości następujące po sobie - -1,0,1,2 etc.
enum TYPES_OF_HEX { TYPE_MIN = -1, NORMAL = 0, FIELD = 1, TREE = 2, TYPE_MAX = 3 }

var fields: Array = []


func _ready() -> void:
	add_field(
		{
			"name": "normal",
			"type": TYPES_OF_HEX.NORMAL,
			"production":
			{
				"wood": 10,
				"water": 10,
				"gold": 5,
				"food": 10,
			}
		}
	)
	add_field(
		{
			"name": "field",
			"type": TYPES_OF_HEX.FIELD,
			"production":
			{
				"wood": 5,
				"water": 15,
				"gold": 2,
				"food": 20,
			}
		}
	)
	add_field(
		{
			"name": "tree",
			"type": TYPES_OF_HEX.TREE,
			"production":
			{
				"wood": 30,
				"water": 15,
				"gold": 3,
				"food": 0,
			}
		}
	)


func add_field(data: Dictionary) -> void:
	assert(data["production"].size() == Resources.resources.size())
	assert(data["production"].has_all(Resources.resources))

	validate_type(data["type"])

	fields.append(data)


func get_field_production(type: int) -> Dictionary:
	validate_type(type)
	return {}


func validate_type(type: int) -> void:
	assert(type > TYPES_OF_HEX.TYPE_MIN && type < TYPES_OF_HEX.TYPE_MAX)
