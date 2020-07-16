extends Node

const PRINT_TESTS: bool = false


func _ready() -> void:
	# Przydatne tylko podczas zmiany kodu, podczas tworzenia gry tylko niepotrzebnie zwiększa czas do uruchomienia
#	Vector2j_test()
#	for i in range(1): # Stress test wykonać dla wartości > 5
#		map_test()

	print("Wykonano wszystkie testy")


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

	var map: Spatial
	var map_array: Array

	map = MapCreator.generate_partial_map(map_array, Vector2(13, 13), 75)
	assert(check_integration_of_map(map, 13, 13))
	map.queue_free()
	map = MapCreator.generate_partial_map(map_array, Vector2(9, 9), 75)
	assert(check_integration_of_map(map, 9, 9))
	map.queue_free()
	map = MapCreator.generate_partial_map(map_array, Vector2(15, 3), 75)
	assert(check_integration_of_map(map, 15, 3))
	map.queue_free()
	map = MapCreator.generate_full_map(map_array, Vector2(15, 3))
	assert(check_integration_of_map(map, 15, 3))
	map.queue_free()
	map = MapCreator.generate_full_map(map_array, Vector2(13, 13))
	assert(check_integration_of_map(map, 13, 13))
	map.queue_free()


# Sprawdza jedynie czy nie ma POJEDYNCZYCH odłączonych wysepek, nie jest to w 100% pewny test, ale przy wykorzystaniu dużych map lub testowaniu stresowym powinno wywalić błędy jeśli są
func check_integration_of_map(map: Spatial, x, y) -> bool:
	var found_hex: bool = false
	var temp_node: Node
	var neightbour: Node

	for i in range(y):
		for j in range(x):
			temp_node = map.get_node_or_null("SingleHex" + str(i * x + j))
			if temp_node != null:
				found_hex = true

				if y % 2 == 0:
					neightbour = map.get_node_or_null("SingleHex" + str((i - 1) * x + (j - 1)))
					if neightbour != null:
						continue
					neightbour = map.get_node_or_null("SingleHex" + str((i - 1) * x + j))
					if neightbour != null:
						continue
					neightbour = map.get_node_or_null("SingleHex" + str(i * x + (j - 1)))
					if neightbour != null:
						continue
					neightbour = map.get_node_or_null("SingleHex" + str(i * x + (j + 1)))
					if neightbour != null:
						continue
					neightbour = map.get_node_or_null("SingleHex" + str((i + 1) * x + (j - 1)))
					if neightbour != null:
						continue
					neightbour = map.get_node_or_null("SingleHex" + str((i + 1) * x + j))
					if neightbour != null:
						continue
					assert(false, "Ktoś nie ma sąsiada")

				pass

	assert(found_hex)  # Zabezpieczenie przed szukaniem dzieci danego węzła ze złą nazwą, lub brakiem węzłów w danej mapie

	for i in map.get_children():
		i.set_name(i.get_name())

	return true
	pass
