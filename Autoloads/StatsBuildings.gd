extends Node

enum TYPES_OF_BUILDINGS { BUILDING_MIN = -1, ANTHILL = 0, FARM = 1, SAWMILL=2, BARRACKS=3, BUILDING_MAX = 4 }

const NUMBER_OF_BUILDINGS = 4

var all_buildings: Array = []
var buildings_types : Array = []

const BASIC_RESOURCES_PER_FIELD : Dictionary = {
		"wood": 3,
		"water": 4,
		"gold": 2,
		"food": 5,
}

const DOWNGRADE_COST : float = 0.8 # Only 80% of value can be restored from 

# Koszty budowy to L1 -> L2 a później ulepszania L2 -> L3 etc. a nie wartości L0 -> L1, L0 -> L2 etc.
func _ready() -> void:
	var default: Dictionary = {
		"wood": 0,
		"water": 0,
		"gold": 0,
		"food": 0,
	}
	building_add(
		"Anthill",
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
		],
		[
			default,
			default,
			default
		]
	)  
	building_add(
		"Farm",
		TYPES_OF_BUILDINGS.FARM,
		3,
		[
			{"wood": 100, "water": 20, "gold": 5, "food": 80},
			{"wood": 100, "water": 40, "gold": 70, "food": 90},
			{"wood": 200, "water": 60, "gold": 560, "food": 20},
		],
		[
			{"wood": 2, "water": 2, "gold": 0, "food": 25},
			{"wood": 5, "water": 5, "gold": 0, "food": 40},
			{"wood": 5, "water": 10, "gold": 1, "food": 70},
		],
		[
			default,
			default,
			default
		]
	)  
	building_add(
		"Sawmill",
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
		],
		[
			default,
			default,
			default
		]
	)  
	building_add(
		"Barracks",
		TYPES_OF_BUILDINGS.BARRACKS,
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
		],
		[
			default,
			default,
			default
		]
	)  

# Returns resources how much needs to build
func get_building_to_build(type : int, level : int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["to_build"][level - 1].duplicate()
	assert(false, "Failed to find building of type " + str(type))
	return {}
	
func get_building_production(type : int, level : int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["production"][level - 1].duplicate()
	assert(false, "Failed to find building of type " + str(type))
	return {}
	
func get_building_usage(type : int, level : int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["usage"][level - 1].duplicate()
	assert(false, "Failed to find building of type " + str(type))
	return {}

func get_bulding_name(type : int) -> String:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["name"]
	assert(false, "Failed to find building of type " + str(type))
	return ""

func building_add(name: String,type : int, levels: int, to_build: Array, production: Array, usage:Array):
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
		"usage": usage,
	}

	all_buildings.append(building_info)
	buildings_types.append(type)


func validate_building(building : int) -> void:
	assert(building > TYPES_OF_BUILDINGS.BUILDING_MIN && building < TYPES_OF_BUILDINGS.BUILDING_MAX)
