extends Node

enum TYPES_OF_ANTS { NO_UNIT = -100, ANT_MIN = 0, WORKER, SWORDMAN, ARCHER, HORSEMAN, ANT_MAX }
enum TYPES_OF_STATS { STATS_MIN = 1, LIFE, ATTACK, DEFENSE, HAPPINESS, ACTION_POINTS, NUMBER_OF_MOVEMENT }
enum TYPES_OF_HELMETS { UNIT_EXPERIENCE_MIN = 1, BRONZE, SILVER, GOLD }

const HELMETS_DEFENSE: PoolIntArray = PoolIntArray([2, 4, 6])

var ants: Array = []
var helmets: Array = []


func _ready() -> void:
	var default: Dictionary = {
		"wood": 0,
		"water": 0,
		"gold": 0,
		"food": 0,
	}

	add_ant({"name": "worker", "type": TYPES_OF_ANTS.WORKER, "production": default})
	add_ant({"name": "swordman", "type": TYPES_OF_ANTS.SWORDMAN, "production": default})
	add_ant(
		{
			"name": "archer",
			"type": TYPES_OF_ANTS.ARCHER,
			"production":
			{
				"wood": 10,
				"water": 10,
				"gold": 5,
				"food": 10,
			}
		}
	)
	add_ant(
		{
			"name": "horseman",
			"type": TYPES_OF_ANTS.HORSEMAN,
			"production":
			{
				"wood": 5,
				"water": 15,
				"gold": 2,
				"food": 20,
			}
		}
	)


func add_ant(data: Dictionary) -> void:
	assert(data["production"].size() == Resources.resources.size())
	assert(data["production"].has_all(Resources.resources))

#	validate_type(data["type"])

	ants.append(data)

#func get_field_production(type : int) -> Dictionary:
#	validate_type(type)
#	return {}
#
#func validate_type(type : int) -> void:
#	assert(type > TYPES_OF_HEX.TYPE_MIN && type < TYPES_OF_HEX.TYPE_MAX)
