extends Node

enum TYPES_OF_BUILDINGS { BUILDING_MIN = -1, ANTHILL = 0, FARM = 1, SAWMILL = 2, BARRACKS = 3, PILE = 4, GOLD_MINE = 5, BUILDING_MAX = 6 }

const NUMBER_OF_BUILDINGS = 6

var all_buildings: Array = []
var buildings_types: Array = []

const BASIC_RESOURCES_PER_FIELD: Dictionary = {
	"wood": 3,
	"gold": 2,
	"food": 5,
}

const DOWNGRADE_COST: float = 0.8  # Only 80% of value can be restored from


# Koszty budowy to L1 -> L2 a później ulepszania L2 -> L3 etc. a nie wartości L0 -> L1, L0 -> L2 etc.
func _ready() -> void:
	var default: Dictionary = {
		"wood": 0,
		"gold": 0,
		"food": 0,
	}
	building_add(
		"Anthill",
		TYPES_OF_BUILDINGS.ANTHILL,
		3,
		[
			default,  # Always have at least 1 level and cannot be built
			{"wood": 12, "gold": 15, "food": 20},
			{"wood": 14, "gold": 19, "food": 40},
		],
		[
			{"wood": 28, "gold": 30, "food": 30},
			{"wood": 33, "gold": 35, "food": 32},
			{"wood": 36, "gold": 40, "food": 34},
		],
		[
			{"wood": 0, "gold": 0, "food": 0},
			{"wood": 0, "gold": 0, "food": 0},
			{"wood": 0, "gold": 0, "food": 0},
		]
	)
	building_add(
		"Farm",
		TYPES_OF_BUILDINGS.FARM,
		3,
		[
			{"wood": 15, "gold": 3, "food": 6},
			{"wood": 17, "gold": 4, "food": 7},
			{"wood": 19, "gold": 5, "food": 8},
		],
		[
			{"wood": 0, "gold": 0, "food": 21},
			{"wood": 0, "gold": 0, "food": 26},
			{"wood": 0, "gold": 0, "food": 32},
		],
		[
			{"wood": 3, "gold": 1, "food": 0},
			{"wood": 4, "gold": 2, "food": 0},
			{"wood": 5, "gold": 2, "food": 0},
		]
	)
	building_add(
		"Sawmill",
		TYPES_OF_BUILDINGS.SAWMILL,
		3,
		[
			{"wood": 45, "gold": 24, "food": 4},
			{"wood": 60, "gold": 26, "food": 6},
			{"wood": 70, "gold": 30, "food": 8},
		],
		[
			{"wood": 28, "gold": 0, "food": 0},
			{"wood": 32, "gold": 0, "food": 0},
			{"wood": 40, "gold": 0, "food": 0},
		],
		[
			{"wood": 0, "gold": 2, "food": 5},
			{"wood": 0, "gold": 3, "food": 7},
			{"wood": 0, "gold": 5, "food": 9},
		]
	)
	building_add(
		"Barracks",
		TYPES_OF_BUILDINGS.BARRACKS,
		3,
		[
			{"wood": 45, "gold": 24, "food": 40},
			{"wood": 60, "gold": 26, "food": 50},
			{"wood": 70, "gold": 30, "food": 55},
		],
		[
			{"wood": 0, "gold": 0, "food": 0},
			{"wood": 0, "gold": 0, "food": 0},
			{"wood": 0, "gold": 0, "food": 0},
		],
		[
			{"wood": 12, "gold": 8, "food": 18},
			{"wood": 13, "gold": 10, "food": 20},
			{"wood": 14, "gold": 11, "food": 24},
		]
	)
	building_add(
		"Gold Mine",
		TYPES_OF_BUILDINGS.GOLD_MINE,
		3,
		[
			{"wood": 90, "gold": 15, "food": 30},
			{"wood": 120, "gold": 20, "food": 40},
			{"wood": 150, "gold": 25, "food": 50},
		],
		[
			{"wood": 0, "gold": 15, "food": 0},
			{"wood": 0, "gold": 19, "food": 0},
			{"wood": 0, "gold": 25, "food": 0},
		],
		[
			{"wood": 20, "gold": 0, "food": 13},
			{"wood": 24, "gold": 0, "food": 15},
			{"wood": 28, "gold": 0, "food": 17},
		]
	)
	building_add(
		"Pile",
		TYPES_OF_BUILDINGS.PILE,
		3,
		[
			{"wood": 36, "gold": 4, "food": 8},
			{"wood": 40, "gold": 6, "food": 10},
			{"wood": 45, "gold": 7, "food": 12},
		],
		[
			{"wood": 0, "gold": 0, "food": 0},
			{"wood": 0, "gold": 0, "food": 0},
			{"wood": 0, "gold": 0, "food": 0},
		],
		[
			{"wood": 12, "gold": 1, "food": 9},
			{"wood": 14, "gold": 2, "food": 12},
			{"wood": 16, "gold": 3, "food": 15},
		]
	)


# Returns resources how much needs to build
func get_building_to_build(type: int, level: int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			if level > 2:  # Tak, to nie jest błąd
				var res_to_build: Dictionary = single_building["to_build"][level - 1].duplicate()
				Resources.remove_resources(res_to_build, single_building["to_build"][level - 2].duplicate())
				return res_to_build

			return single_building["to_build"][level - 1].duplicate()
	assert(false, "Failed to find building of type " + str(type))
	return {}


func get_building_production(type: int, level: int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["production"][level - 1].duplicate()
	assert(false, "Failed to find building of type " + str(type))
	return {}


func get_building_usage(type: int, level: int) -> Dictionary:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["usage"][level - 1].duplicate()
	assert(false, "Failed to find building of type " + str(type))
	return {}


func get_bulding_name(type: int) -> String:
	validate_building(type)
	for single_building in all_buildings:
		if single_building["type"] == type:
			return single_building["name"]
	assert(false, "Failed to find building of type " + str(type))
	return ""


func building_add(name: String, type: int, levels: int, to_build: Array, production: Array, usage: Array):
	assert(levels > 1 && levels < 4)  # Pomiędzy 1 a 3 są dostępne poziomy budynków

	assert(to_build.size() == levels)
	assert(production.size() == levels)
	for i in to_build + production:
		assert(i.has_all(["wood", "gold", "food"]))
		for j in i.values():
			assert(j >= 0)

	var building_info: Dictionary = {
		"name": name,
		"type": type,
		"use_each_turn": {},
		"levels": levels,
		"to_build": to_build,
		"production": production,
		"usage": usage,
	}

	all_buildings.append(building_info)
	buildings_types.append(type)


func validate_building(building: int) -> void:
	assert(building > TYPES_OF_BUILDINGS.BUILDING_MIN && building < TYPES_OF_BUILDINGS.BUILDING_MAX)
