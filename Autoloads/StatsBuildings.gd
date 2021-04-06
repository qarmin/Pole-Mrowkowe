extends Node

enum TYPES_OF_BUILDINGS { BUILDING_MIN = -1, ANTHILL = 0, BUILDING_MAX = 1 }

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
		3,
		[
			default,
			{"wood": 100, "water": 0, "gold": 0, "food": 0},
			{"wood": 200, "water": 0, "gold": 0, "food": 0},
		],
		[
			{"wood": 12, "water": 20, "gold": 10, "food": 5},
			{"wood": 24, "water": 20, "gold": 20, "food": 20},
			{"wood": 36, "water": 36, "gold": 20, "food": 20},
		]
	)  # Always have at least 1 level and cannot be built


func add_building(name: String, levels: int, to_build: Array, production: Array):
	assert(levels > 1 && levels < 4)  # Pomiędzy 1 a 3 są dostępne poziomy budynków

	assert(to_build.size() == levels)
	assert(production.size() == levels)
	for i in to_build + production:
		assert(i.has_all(["wood", "water", "gold", "food"]))
		for j in i.values():
			assert(j >= 0)

	var building_info: Dictionary = {
		"name": name,
		"use_each_turn": {},
		"levels": levels,
		"to_build": to_build,
		"production": production,
	}

	all_buildings.append(building_info)

	pass

func validate_building(building : int) -> void:
	assert(building > TYPES_OF_BUILDINGS.BUILDING_MIN && building < TYPES_OF_BUILDINGS.BUILDING_MAX)
