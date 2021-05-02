extends Node

enum TYPES_OF_ANTS { NO_UNIT = -100, ANT_MIN = 0, WORKER, SWORDMAN, FLYER, ANT_MAX }
enum TYPES_OF_STATS { STATS_MIN = -1, ANTS, ATTACK, DEFENSE, LUCK, ACTION_POINTS, NUMBER_OF_MOVEMENT, STATS_MAX }
enum TYPES_OF_ARMOR { ARMOR_MIN = 0, BRONZE, SILVER, GOLD }

const HELMETS_DEFENSE: PoolIntArray = PoolIntArray([2, 4, 6])

var ants: Array = []
var armors: Array = []


func _ready() -> void:
	var default: Dictionary = {
		"wood": 0,
		"water": 0,
		"gold": 0,
		"food": 0,
	}
	var stats_default : Dictionary = {
		"ants" : 100,
		"defense" : 10,
		"attack" : 10,
		"luck" : 40,
		"action_points" : 2,
		"number_of_movement" : 1,
	}
	

	# TODO change Usage to normal
	add_ant({"name": "worker", "type": TYPES_OF_ANTS.WORKER, "production": default, "usage":default, "stats" : stats_default, "armor" : TYPES_OF_ARMOR.BRONZE})
	add_ant({"name": "swordman", "type": TYPES_OF_ANTS.SWORDMAN, "production": default, "usage":default, "stats" : stats_default, "armor" : TYPES_OF_ARMOR.BRONZE})
	add_ant(
		{
			"name": "archer",
			"type": TYPES_OF_ANTS.FLYER,
			"production":
			{
				"wood": 10,
				"water": 10,
				"gold": 5,
				"food": 10,
			},
			"usage":
				{
				"wood": 10,
				"water": 10,
				"gold": 5,
				"food": 10,
				},
			"stats": stats_default,
			"armor" : TYPES_OF_ARMOR.BRONZE,
		}
	)

func add_armor(_data: Dictionary) -> void:
	#TODO
	pass

func add_ant(data: Dictionary) -> void:
	assert(data["production"].size() == Resources.resources.size())
	assert(data["production"].has_all(Resources.resources))
	assert(data["usage"].size() == Resources.resources.size())
	assert(data["usage"].has_all(Resources.resources))
	assert(data["stats"].size() == TYPES_OF_STATS.STATS_MAX)

	validate_type(data["type"])
	

	ants.append(data)

func get_unit_usage(type : int) -> Dictionary:
	validate_type(type)
	for ant in ants:
		if ant["type"] == type:
			return ant["usage"].duplicate()
			
	assert(false, "Failed to found proper ant for this usage") 
	return {}

func validate_type(type : int) -> void:
	assert(type > TYPES_OF_ANTS.ANT_MIN && type < TYPES_OF_ANTS.ANT_MAX)
