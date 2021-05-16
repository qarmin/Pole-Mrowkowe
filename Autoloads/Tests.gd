extends Node

const PRINT_TESTS: bool = true


# Używane tylko przy zmianach kodu dlatego, że spowalnia działanie gry
func _ready() -> void:
	# Przydatne tylko podczas zmiany kodu, podczas tworzenia gry tylko niepotrzebnie zwiększa czas do uruchomienia
	if false:
		return
	Vector2j_test()
	resources()
	building_test()
	if true:
		return
	for _i in range(10):  # Stress test wykonać dla wartości > 5
		Vector2j_test()
		resources()
		building_test()
		map_test()
		shrink_map()
#		save_load_test() # TODO
	print("Wykonano wszystkie testy")
	pass


func resources() -> void:
	if PRINT_TESTS:
		print("Wykonuję test Resources")

	assert(Resources.are_all_resources_positive({"wood": 0, "food": 100, "gold": 52, "water": 40}))
	assert(!Resources.are_all_resources_positive({"wood": -100, "food": 100, "gold": 52, "water": 40}))

	var dict: Dictionary = {"wood": -100, "food": 100, "gold": 52, "water": 40}
	Resources.normalize_resources(dict)
	assert(dict["wood"] == 0)
	assert(dict["food"] == 100)

	var first: Dictionary = {"wood": -100, "food": 100, "gold": 52, "water": 40}
	var second: Dictionary = {"wood": 30, "food": 150, "gold": 48, "water": 120}
	Resources.add_resources(first, second)
	assert(first["wood"] == -70 && first["food"] == 250 && first["gold"] == 100 && first["water"] == 160)
	assert(second["wood"] == 30 && second["food"] == 150 && second["gold"] == 48 && second["water"] == 120)

	var third: Dictionary = {"wood": -100, "food": 100, "gold": 52, "water": 40}
	var forth: Dictionary = {"wood": 30, "food": 150, "gold": 48, "water": 120}
	Resources.remove_resources(third, forth)
	assert(third["wood"] == -130 && third["food"] == -50 && third["gold"] == 4 && third["water"] == -80)
	assert(forth["wood"] == 30 && forth["food"] == 150 && forth["gold"] == 48 && forth["water"] == 120)

	var roman: Dictionary = {"wood": 80, "food": 40, "gold": 20, "water": 5}
	Resources.scale_resources(roman, 0.7)
	assert(roman["wood"] == 56)
	assert(roman["food"] == 28)
	assert(roman["gold"] == 14)
	assert(roman["water"] == 3)


func building_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test Budowania")
	var single_map: SingleMap = SingleMap.new()
	MapCreator.create_map(single_map, Vector2j.new(10, 1), 5)
	single_map.building_add(Vector2j.new(9, 0), Buildings.TYPES_OF_BUILDINGS.ANTHILL, 1)
	single_map.building_add(Vector2j.new(9, 0), Buildings.TYPES_OF_BUILDINGS.FARM, 1)
	assert(single_map.buildings[0][9].size() == 2)
	single_map.building_change_level(Vector2j.new(9, 0), Buildings.TYPES_OF_BUILDINGS.ANTHILL, 3)
	assert(single_map.buildings[0][9][Buildings.TYPES_OF_BUILDINGS.ANTHILL]["level"] == 3)
	single_map.building_remove(Vector2j.new(9, 0), Buildings.TYPES_OF_BUILDINGS.FARM)
	assert(single_map.buildings[0][9].size() == 1)
	single_map.building_remove(Vector2j.new(9, 0), Buildings.TYPES_OF_BUILDINGS.ANTHILL)
	assert(single_map.buildings[0][9].size() == 0)
	pass


func Vector2j_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test Vector2j")
	var vec_1: Vector2j = Vector2j.new(1, 3)
	var vec_2: Vector2j = Vector2j.new(125, 13)
	var vec_3: Vector2j = Vector2j.new(42, 25)
	var vec_4: Vector2j = Vector2j.new(25, 3)
	var vec_5: Vector2j = Vector2j.new(31, 25)

	assert(vec_1.x == 1)
	assert(vec_1.y == 3)

	var array: Array = []

	array.append(Vector2j.new(1, 3))
	array.append(Vector2j.new(2, 3))
	array.append(Vector2j.new(1, 100))
	array.append(Vector2j.new(125, 12))
	array.append(Vector2j.new(25, 31))

	assert(Vector2j.is_in_array(array, vec_1))
	assert(!Vector2j.is_in_array(array, vec_2))
	assert(!Vector2j.is_in_array(array, vec_3))
	assert(!Vector2j.is_in_array(array, vec_4))
	assert(Vector2j.is_in_array_reversed(array, vec_5))
	assert(Vector2j.is_in_array(array, Vector2j.new(1, 3)))
	assert(!Vector2j.is_in_array(array, Vector2j.new(125, 13)))
	assert(!Vector2j.is_in_array(array, Vector2j.new(42, 25)))
	assert(!Vector2j.is_in_array(array, Vector2j.new(25, 3)))
	assert(Vector2j.is_in_array_reversed(array, Vector2j.new(31, 25)))


func map_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test map")

	var single_map: SingleMap = SingleMap.new()

	MapCreator.create_map(single_map, Vector2j.new(6, 6), 4)
	SingleMap.validate_sizes_of_arrays(single_map)
	assert(check_integration_of_map(single_map))
# warning-ignore:return_value_discarded
	MapCreator.populate_map_randomly_playable(single_map, 4)

	MapCreator.create_map(single_map, Vector2j.new(13, 13), 4)
	SingleMap.validate_sizes_of_arrays(single_map)
	assert(check_integration_of_map(single_map))
# warning-ignore:return_value_discarded
	MapCreator.populate_map_realistically(single_map, 4)

	MapCreator.create_map(single_map, Vector2j.new(9, 9), 4)
	SingleMap.validate_sizes_of_arrays(single_map)
	assert(check_integration_of_map(single_map))
# warning-ignore:return_value_discarded
	MapCreator.populate_map_realistically(single_map, 3)

	MapCreator.create_map(single_map, Vector2j.new(4, 7), 4)
	SingleMap.validate_sizes_of_arrays(single_map)
	assert(check_integration_of_map(single_map))
# warning-ignore:return_value_discarded
	MapCreator.populate_map_randomly(single_map, 3)

	MapCreator.create_map(single_map, Vector2j.new(15, 3), 4)
	SingleMap.validate_sizes_of_arrays(single_map)
	assert(check_integration_of_map(single_map))
# warning-ignore:return_value_discarded
	MapCreator.populate_map_realistically(single_map, 2)

	MapCreator.create_map(single_map, Vector2j.new(15, 3), 5)
	SingleMap.validate_sizes_of_arrays(single_map)
	assert(check_integration_of_map(single_map))
# warning-ignore:return_value_discarded
	MapCreator.populate_map_realistically(single_map, 4)

	MapCreator.create_map(single_map, Vector2j.new(13, 13), 5)
	SingleMap.validate_sizes_of_arrays(single_map)
# warning-ignore:return_value_discarded
	MapCreator.populate_map_realistically(single_map, 2)
	assert(check_integration_of_map(single_map))

	MapCreator.create_map(single_map, Vector2j.new(20, 10), 5)
	SingleMap.validate_sizes_of_arrays(single_map)
# warning-ignore:return_value_discarded
	MapCreator.populate_map_realistically(single_map, 4)
	assert(check_integration_of_map(single_map))

	MapCreator.create_map(single_map, Vector2j.new(10, 20), 5)
	SingleMap.validate_sizes_of_arrays(single_map)
# warning-ignore:return_value_discarded
	MapCreator.populate_map_randomly(single_map, 3)
	assert(check_integration_of_map(single_map))

	MapCreator.create_map(single_map, Vector2j.new(30, 6), 5)
	SingleMap.validate_sizes_of_arrays(single_map)
# warning-ignore:return_value_discarded
	MapCreator.populate_map_randomly(single_map, 4)
	assert(check_integration_of_map(single_map))

	single_map.reset()


func shrink_map():
	if PRINT_TESTS:
		print("Wykonuję test przycinania mapy")

	var single_map: SingleMap = SingleMap.new()
	## Test map shrinking
	var temp_spatial: Spatial
	single_map.map = Spatial.new()
	temp_spatial = Spatial.new()
	temp_spatial.set_name(MapCreator.NODE_BASE_NAME + "2")
	single_map.map.add_child(temp_spatial)
	temp_spatial = Spatial.new()
	temp_spatial.set_name(MapCreator.NODE_BASE_NAME + "4")
	single_map.map.add_child(temp_spatial)
	temp_spatial = Spatial.new()
	temp_spatial.set_name(MapCreator.NODE_BASE_NAME + "5")
	single_map.map.add_child(temp_spatial)

	single_map.set_size(Vector2j.new(3, 3))
	single_map.initialize_fields(SingleMap.FIELD_TYPE.DEFAULT_FIELD)
	single_map.set_number_of_terrain(3)
	# Trzeba pamiętać, że istnieje pole zawsze w punkcie (0,0)
	single_map.fields = [
		[SingleMap.FIELD_TYPE.PLAYER_FIRST, SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD],
		[SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD],
		[SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.NO_FIELD]
	]

	single_map.shrink_map()

	assert(single_map.number_of_terrain == 3)
	assert(single_map.fields.size() == 2)
	assert(single_map.fields[0].size() == 2)
	assert(single_map.fields[1].size() == 2)

	var expected_fields: Array = [[SingleMap.FIELD_TYPE.PLAYER_FIRST, SingleMap.FIELD_TYPE.DEFAULT_FIELD], [SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD]]

	assert(single_map.fields == expected_fields)

	single_map.reset()


# Sprawdza jedynie czy nie ma POJEDYNCZYCH odłączonych wysepek
func check_integration_of_map(single_map: SingleMap) -> bool:
	var checked: Array = []
	var to_check: Array = []
	var current_element: Vector2j = Vector2j.new(0, 0)

	# Pewny punkt startowy to 0,0
	to_check.append(Vector2j.new(0, 0))

	# Sprawdza do ilu hexów jest dostęp z hexa (0,0), jeśli różni się od liczby wszystkich hexów, to znaczy, że znaczy istnieją oderwane hexy
	while to_check.size() > 0:
		current_element = to_check.pop_front()

		var help_array = [[[0, -1], [1, -1], [-1, 0], [1, 0], [0, 1], [1, 1]], [[-1, -1], [0, -1], [-1, 0], [1, 0], [-1, 1], [0, 1]]]

		for h in [0, 1]:
			if current_element.y % 2 == ((h + 1) % 2):
				for i in range(6):
					if (
						(current_element.x + help_array[h][i][0] >= 0)
						&& (current_element.x + help_array[h][i][0] < int(single_map.size.x))
						&& (current_element.y + help_array[h][i][1] >= 0)
						&& (current_element.y + help_array[h][i][1] < int(single_map.size.y))
					):
						var cep_x = current_element.x + help_array[h][i][0]
						var cep_y = current_element.y + help_array[h][i][1]
						if !Vector2j.is_in_array(checked, Vector2j.new(cep_x, cep_y)) && !Vector2j.is_in_array(to_check, Vector2j.new(cep_x, cep_y)):
							if single_map.fields[cep_y][cep_x] != SingleMap.FIELD_TYPE.NO_FIELD:
								to_check.append(Vector2j.new(cep_x, cep_y))

		assert(!Vector2j.is_in_array(checked, current_element))

		checked.append(current_element)

	assert(checked.size() == single_map.number_of_terrain)

	return checked.size() == single_map.number_of_terrain

#func save_load_test() -> void:
#	if PRINT_TESTS:
#		print("Wykonuję test zapisywania")
#
#	var single_map: SingleMap = SingleMap.new()
#	var loaded_single_map: SingleMap = SingleMap.new()
#
#	MapCreator.create_map(single_map, Vector2j.new(7, 13), 75)
#	assert(check_integration_of_map(single_map))
#	if !MapCreator.populate_map_realistically(single_map, 4):
#		push_error("Nie powiodła się próba mapy")
#		assert(false)
#
#	SaveSystem.save_map_as_text(single_map, 100)
#	loaded_single_map = SaveSystem.load_map_from_text(100)
#
#	## Size
#	assert(single_map.size.x == loaded_single_map.size.x)
#	assert(single_map.size.y == loaded_single_map.size.y)
#	## Units
#	assert(loaded_single_map.units.size() == single_map.units.size())
#	for i in range(loaded_single_map.units.size()):
#		assert(loaded_single_map.units[i].size() == single_map.units[i].size())
#		for j in range(loaded_single_map.units[0].size()):
#			assert(loaded_single_map.units[i][j] == single_map.units[i][j])
#	## Fields
#	assert(loaded_single_map.fields.size() == single_map.fields.size())
#	for i in range(loaded_single_map.fields.size()):
#		assert(loaded_single_map.fields[i].size() == single_map.fields[i].size())
#		for j in range(loaded_single_map.fields[0].size()):
#			assert(loaded_single_map.fields[i][j] == single_map.fields[i][j])
#	## Buildings
#	assert(loaded_single_map.buildings.size() == single_map.buildings.size())
#	for i in range(loaded_single_map.buildings.size()):
#		assert(loaded_single_map.buildings[i].size() == single_map.buildings[i].size())
#		for j in range(loaded_single_map.buildings[0].size()):
#			assert(loaded_single_map.buildings[i][j] == single_map.buildings[i][j])
#	## Nature
#	assert(loaded_single_map.nature.size() == single_map.nature.size())
#	for i in range(loaded_single_map.nature.size()):
#		assert(loaded_single_map.nature[i].size() == single_map.nature[i].size())
#		for j in range(loaded_single_map.nature[0].size()):
#			assert(loaded_single_map.nature[i][j] == single_map.nature[i][j])
#
#	return
