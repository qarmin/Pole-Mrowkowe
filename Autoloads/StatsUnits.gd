extends Node

enum TYPES_OF_ANTS { NO_UNIT = -100, ANT_MIN = -1, WORKER, SOLDIER, FLYING, ANT_MAX }
enum TYPES_OF_STATS { STATS_MIN = -1, ANTS, ATTACK, DEFENSE, NUMBER_OF_MOVEMENT, STATS_MAX }  # Luck, ACTION_POINTS
enum TYPES_OF_ARMOR { ARMOR_MIN = 0, BRONZE, SILVER, GOLD }

const HELMETS_DEFENSE: PoolIntArray = PoolIntArray([2, 4, 6])

var ants: Array = []
var armors: Array = []

var units_types: Array = []

const DOWNGRADE_COST: float = 0.8  # Only 80% of value can be restored from


func _ready() -> void:
#	var default: Dictionary = {
#		"wood": 200,
#		"gold": 200,
#		"food": 200,
#	}
#	var stats_default: Dictionary = {
#		"attack": 30,
#		"defense": 30,
#		"ants": 100,
#		"number_of_movement": 10,
#	}
#		"luck": 40,
#		"action_points": 2,

	add_ant(
		{
			"name": "Worker",
			"type": TYPES_OF_ANTS.WORKER,
			"to_build":
			{
				"wood": 7,
				"gold": 15,
				"food": 16,
			},
			"usage":
			{
				"wood": 5,
				"gold": 10,
				"food": 15,
			},
			"stats":
			{
				"attack": 30,
				"defense": 20,
				"ants": 100,
				"number_of_movement": 1,
			},
			"armor": TYPES_OF_ARMOR.BRONZE
		}
	)
	add_ant(
		{
			"name": "Soldier",
			"type": TYPES_OF_ANTS.SOLDIER,
			"to_build":
			{
				"wood": 12,
				"gold": 30,
				"food": 15,
			},
			"usage":
			{
				"wood": 5,
				"gold": 15,
				"food": 20,
			},
			"stats":
			{
				"attack": 45,
				"defense": 40,
				"ants": 100,
				"number_of_movement": 1,
			},
			"armor": TYPES_OF_ARMOR.BRONZE
		}
	)
	add_ant(
		{
			"name": "Flying",
			"type": TYPES_OF_ANTS.FLYING,
			"to_build":
			{
				"wood": 25,
				"gold": 40,
				"food": 10,
			},
			"usage":
			{
				"wood": 10,
				"gold": 20,
				"food": 20,
			},
			"stats":
			{
				"attack": 35,
				"defense": 10,
				"ants": 100,
				"number_of_movement": 2,
			},
			"armor": TYPES_OF_ARMOR.BRONZE,
		}
	)


func add_armor(_data: Dictionary) -> void:
	#TODO
	pass


func add_ant(data: Dictionary) -> void:
	assert(data["to_build"].size() == Resources.resources.size())
	assert(data["to_build"].has_all(Resources.resources))
	assert(data["usage"].size() == Resources.resources.size())
	assert(data["usage"].has_all(Resources.resources))
	assert(data["stats"].size() == TYPES_OF_STATS.STATS_MAX)

	assert(data["stats"]["defense"] <= 40)  # Powinno by?? zawsze mniejsze ni?? x
	assert(data["stats"]["attack"] < 50)  # Powinno by?? zawsze mniejsze ni?? x
	assert(data["stats"]["number_of_movement"] > 0)

	validate_type(data["type"])

	ants.append(data)
	units_types.append(data["type"])


func get_unit_name(type: int) -> String:
	validate_type(type)
	for single_unit in ants:
		if single_unit["type"] == type:
			return single_unit["name"]
	assert(false, "Failed to find unit of type " + str(type))
	return ""


func get_unit_usage(type: int, _level: int) -> Dictionary:
	validate_type(type)
	for ant in ants:
		if ant["type"] == type:
			return ant["usage"].duplicate()
	assert(false, "Failed to found proper ant for this usage")
	return {}


func get_unit_to_build(type: int, _level: int) -> Dictionary:
	validate_type(type)
	for ant in ants:
		if ant["type"] == type:
			return ant["to_build"].duplicate()

	assert(false, "Failed to found proper ant for this usage")
	return {}


func get_default_stats(type: int, _level: int) -> Dictionary:
	validate_type(type)
	for ant in ants:
		if ant["type"] == type:
			return ant["stats"].duplicate()

	assert(false, "Failed to found proper ant for this stats")
	return {}


func validate_type(type: int) -> void:
	assert(type > TYPES_OF_ANTS.ANT_MIN && type < TYPES_OF_ANTS.ANT_MAX)
