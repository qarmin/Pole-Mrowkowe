extends Node

const PRINT_TESTS: bool = false


func _ready() -> void:
	# Przydatne tylko podczas zmiany kodu, podczas tworzenia gry tylko niepotrzebnie zwiększa czas do uruchomienia
#	Vector2j_test()
#	for _i in range(1): # Stress test wykonać dla wartości > 5
#		map_test()
#	print("Wykonano wszystkie testy")
	pass

func Vector2j_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test Vector2j")
	var vec_1: Vector2j = Vector2j.new(1, 3)
	var vec_2: Vector2j = Vector2j.new(125, 13)
	var vec_3: Vector2j = Vector2j.new(42, 25)
	var vec_4: Vector2j = Vector2j.new(25, 3)
	var vec_5: Vector2j = Vector2j.new(31, 25)

	var array: Array = []

	array.append(Vector2j.new(1, 3))
	array.append(Vector2j.new(2, 3))
	array.append(Vector2j.new(1, 100))
	array.append(Vector2j.new(125, 12))
	array.append(Vector2j.new(25, 31))

	assert(Vector2j.is_in_array(array, vec_1))
	assert(! Vector2j.is_in_array(array, vec_2))
	assert(! Vector2j.is_in_array(array, vec_3))
	assert(! Vector2j.is_in_array(array, vec_4))
	assert(Vector2j.is_in_array_reversed(array, vec_5))
	assert(Vector2j.is_in_array(array, Vector2j.new(1, 3)))
	assert(! Vector2j.is_in_array(array, Vector2j.new(125, 13)))
	assert(! Vector2j.is_in_array(array, Vector2j.new(42, 25)))
	assert(! Vector2j.is_in_array(array, Vector2j.new(25, 3)))
	assert(Vector2j.is_in_array_reversed(array, Vector2j.new(31, 25)))


func map_test() -> void:
	if PRINT_TESTS:
		print("Wykonuję test map")

	var single_map: SingleMap = SingleMap.new()

	MapCreator.generate_partial_map(single_map, Vector2(13, 13), 75)
	assert(check_integration_of_map(single_map))
	MapCreator.populate_map(single_map, 4)
	single_map.reset()

	MapCreator.generate_partial_map(single_map, Vector2(9, 9), 75)
	assert(check_integration_of_map(single_map))
	MapCreator.populate_map(single_map, 3)
	single_map.reset()

	MapCreator.generate_partial_map(single_map, Vector2(15, 3), 75)
	assert(check_integration_of_map(single_map))
	MapCreator.populate_map(single_map, 2)
	single_map.reset()

	MapCreator.generate_full_map(single_map, Vector2(15, 3))
	assert(check_integration_of_map(single_map))
	MapCreator.populate_map(single_map, 4)
	single_map.reset()

	MapCreator.generate_full_map(single_map, Vector2(13, 13))
	MapCreator.populate_map(single_map, 2)
	assert(check_integration_of_map(single_map))
	single_map.reset()

	MapCreator.generate_full_map(single_map, Vector2(20, 10))
	MapCreator.populate_map(single_map, 4)
	assert(check_integration_of_map(single_map))
	single_map.reset()


# Sprawdza jedynie czy nie ma POJEDYNCZYCH odłączonych wysepek, nie jest to w 100% pewny test, ale przy wykorzystaniu dużych map lub testowaniu stresowym powinno wywalić błędy jeśli są
func check_integration_of_map(single_map: SingleMap) -> bool:

	var checked: Array = []
	var to_check: Array = []
	var start_point: Vector2j = Vector2j.new(0,0)
	var current_element: Vector2j = Vector2j.new(0,0)

	# Wybiera punkt startowy
	while true:
		start_point.x = randi() % int(single_map.size.x)
		start_point.y = randi() % int(single_map.size.y)
		if single_map.fields[start_point.y][start_point.x] != MapCreator.FIELD_TYPE.NO_FIELD:
			to_check.append(start_point)
			break
	
	# Sprawdza z iloma wszystkimi hexami jest dany hex połączony pośrednio i bezpośrednio, keśli różni się od liczby wszystkich hexów, to znaczy, że istnieją oderwane hexy
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
						if ! Vector2j.is_in_array(checked, Vector2j.new(cep_x, cep_y)) && ! Vector2j.is_in_array(to_check, Vector2j.new(cep_x, cep_y)):
							if single_map.fields[cep_y][cep_x] != MapCreator.FIELD_TYPE.NO_FIELD:
								to_check.append(Vector2j.new(cep_x, cep_y))

		assert(! Vector2j.is_in_array(checked, current_element))

		checked.append(current_element)
	
	assert(checked.size() == single_map.number_of_terrain)
	
	return checked.size() == single_map.number_of_terrain
