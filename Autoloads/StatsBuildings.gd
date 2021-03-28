extends Node

enum TYPES_OF_BUILDINGS { NO_BUILDING = 0, ANTHILL = 1, HOUSE = 2, ANT_MAX = 4 }

var all_buildings: Array = []


# Koszty budowy to L1 -> L2 a później ulepszania L2 -> L3 etc.
func _ready() -> void:
	var default: Dictionary = {"wood": 0, "water": 0, "gold": 0, "food": 0,}
	add_building(
		"capitol",
		3,
		default,
		{"wood": 100, "water": 0, "gold": 0, "food": 0},
		{"wood": 200, "water": 0, "gold": 0, "food": 0}
	)  # Always have at least 1 level and cannot be built


func add_building(name: String, levels: int, to_build_level_1: Dictionary, to_build_level_2: Dictionary, to_build_level_3: Dictionary):
	assert(levels > 1 && levels < 4)  # Pomiędzy 1 a 3 są dostępne poziomy budynków

	var building_info: Dictionary = {
		"name": name,
		"use_each_turn": {},
		"levels": levels,
		"to_build_level_1": to_build_level_1,
		"to_build_level_2": to_build_level_2,
		"to_build_level_3": to_build_level_3
	}

	for i in [to_build_level_1, to_build_level_2, to_build_level_3]:
		assert(i.size() == Resources.resources.size())
		assert(i.has_all(Resources.resources))

	all_buildings.append(building_info)

	pass
