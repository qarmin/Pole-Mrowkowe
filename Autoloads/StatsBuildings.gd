extends Node

enum TYPES_OF_BUILDINGS { BUILDING_MIN = -1, ANTHILL = 0, FARM = 1, SAWMILL=2, BUILDING_MAX = 3 }

var all_buildings: Array = []


# Koszty budowy to L1 -> L2 a później ulepszania L2 -> L3 etc.
func _ready() -> void:
	var default: Dictionary = {
		"wood": 0,
		"water": 0,
		"gold": 0,
		"food": 0,
	}
	add_building(
		"anthill",
		TYPES_OF_BUILDINGS.ANTHILL,
		3,
		[
			default, # Always have at least 1 level and cannot be built
			{"wood": 100, "water": 40, "gold": 60, "food": 80},
			{"wood": 200, "water": 20, "gold": 70, "food": 40},
		],
		[
			{"wood": 12, "water": 20, "gold": 10, "food": 5},
			{"wood": 24, "water": 20, "gold": 20, "food": 20},
			{"wood": 36, "water": 36, "gold": 20, "food": 20},
		]
	)  
	add_building(
		"farm",
		TYPES_OF_BUILDINGS.FARM,
		3,
		[
			{"wood": 100, "water": 20, "gold": 5, "food": 80},
			{"wood": 100, "water": 40, "gold": 70, "food": 90},
			{"wood": 200, "water": 60, "gold": 80, "food": 20},
		],
		[
			{"wood": 2, "water": 2, "gold": 0, "food": 25},
			{"wood": 5, "water": 5, "gold": 0, "food": 40},
			{"wood": 5, "water": 10, "gold": 1, "food": 70},
		]
	)  
	add_building(
		"sawmill",
		TYPES_OF_BUILDINGS.SAWMILL,
		3,
		[
			{"wood": 100, "water": 20, "gold": 1, "food": 3},
			{"wood": 100, "water": 40, "gold": 2, "food": 4},
			{"wood": 200, "water": 60, "gold": 3, "food": 5},
		],
		[
			{"wood": 2, "water": 2, "gold": 0, "food": 25},
			{"wood": 5, "water": 5, "gold": 0, "food": 40},
			{"wood": 5, "water": 10, "gold": 1, "food": 70},
		]
	)  

func get_building_to_build(type : int, level : int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["to_build"][level -1]
	assert(false, "Failed to find")
	return {}

func add_building(name: String,type : int, levels: int, to_build: Array, production: Array):
	assert(levels > 1 && levels < 4)  # Pomiędzy 1 a 3 są dostępne poziomy budynków

	assert(to_build.size() == levels)
	assert(production.size() == levels)
	for i in to_build + production:
		assert(i.has_all(["wood", "water", "gold", "food"]))
		for j in i.values():
			assert(j >= 0)

	var building_info: Dictionary = {
		"name": name,
		"type" : type,
		"use_each_turn": {},
		"levels": levels,
		"to_build": to_build,
		"production": production,
	}

	all_buildings.append(building_info)

	pass

func validate_building(building : int) -> void:
	assert(building > TYPES_OF_BUILDINGS.BUILDING_MIN && building < TYPES_OF_BUILDINGS.BUILDING_MAX)
