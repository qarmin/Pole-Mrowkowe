class_name SingleMap

var map: Spatial = null
var size: Vector2j
var fields: Array  # Dwuwymiarowa tablica z zaznaczonymi polami, gdzie które się znajduje, tak aby nie trzeba było cały czas sięgać po tablicę
var units: Array
var nature: Array
var preview: Image = Image.new()
var number_of_terrain: int
var number_of_all_possible_hexes: int
var players: Array  # Pozycje bazowe na mapie, nie wiem do końca do czego mogłoby się to przydać, ale może być przydatne do stawiania początkowej bazy
var buildings: Array  # Tablica z budynkami
var real_map_size: Vector3  # Rzeczywista wielkość mapy

## Zmienne sprawdzające czy dla danej mapy była wykonywana dana operacja, przydatne tylko do debugowania
var was_resetted: bool = false
var was_shrinked: bool = false


func reset() -> void:
	if map != null:
		map.queue_free()
		map = null

	preview = Image.new()
	size = Vector2j.new(0, 0)
	fields.clear()
	units.clear()
	nature.clear()
	number_of_terrain = 0
	number_of_all_possible_hexes = 0
	players.clear()
	buildings.clear()
	real_map_size = Vector3()

	was_resetted = true


## Settery


func set_size(new_size: Vector2j) -> void:
	size = new_size

	number_of_all_possible_hexes = size.x * size.y


func set_players(new_players: Array) -> void:
	players = new_players


func set_map(new_map: Spatial) -> void:
	assert(map == null)  # Nie wyczyszczono starej mapy poprawnie
	map = new_map
	shrink_map()  # Usuwa niepotrzebne tereny 


func set_number_of_terrain(new_number_of_terrain: int) -> void:
	number_of_terrain = new_number_of_terrain


func set_preview(new_preview: Image) -> void:
	preview = new_preview


## Inne funkcje


## Inicjalizacja terenów, jednostek na nich i budynków
func initialize_fields(type_of_field: int):
	assert(type_of_field == MapCreator.FIELD_TYPE.DEFAULT_FIELD or type_of_field == MapCreator.FIELD_TYPE.NO_FIELD)
	assert(fields.size() == 0)
	fields.clear()
	units.clear()
	buildings.clear()
	nature.clear()
	for y in range(size.y):
		fields.append([])
		units.append([])
		buildings.append([])
		nature.append([])
		for _x in range(size.x):
			fields[y].append(type_of_field)
			units[y].append(Units.TYPES_OF_ANTS.NO_UNIT)
			buildings[y].append(Buildings.TYPES_OF_BUILDINGS.NO_BUILDING)
			nature[y].append(HexNature.TYPES_OF_HEX.NOTHING)
	assert(fields.size() == units.size())
	assert(fields.size() == buildings.size())


## Oblicza liczbę terenów na mapie
## Należy ją wykonać po ustawieniu tablicy fields
func calculate_number_of_terrains():
	number_of_terrain = 0
	for y in range(size.y):
		for x in range(size.x):
			if fields[y][x] != MapCreator.FIELD_TYPE.NO_FIELD:
				number_of_terrain += 1


## Odpowiada za przycięcie mapy jeśli nie została nie ma wymiarów zakładanych przez gracza
func shrink_map() -> void:
	var real_max_x: int = -1
	var real_max_y: int = -1

#	print_map(fields)
	for y in size.y:
		for x in size.x:
			if fields[y][x] != MapCreator.FIELD_TYPE.NO_FIELD:
				if real_max_x == -1:
					real_max_x = x
				else:
					if real_max_x < x:
						real_max_x = x
				if real_max_y == -1:
					real_max_y = y
				else:
					if real_max_y < y:
						real_max_y = y

	if (real_max_x + 1) != fields[0].size() || (real_max_y + 1) != fields.size():
		was_shrinked = true
		set_size(Vector2j.new(real_max_x + 1, real_max_y + 1))

#		print("INFO: Trzeba przyciąć mapę")

#		print("--- PRZED")
#		print_map(fields)

		fields.resize(size.y)
		units.resize(size.y)
		buildings.resize(size.y)
		nature.resize(size.y)
		for y in range(fields.size()):
			fields[y].resize(size.x)
			units[y].resize(size.x)
			buildings[y].resize(size.x)
			nature[y].resize(size.x)
	validate_sizes_of_arrays(self)  # Needs to be validate, because it may happens that some array have different size after resiszing


#		print("--- PO")
#		print_map(fields)

#	else:
#		print("INFO: Nie trzeba zmniejszać mapy")

static func validate_sizes_of_arrays(single_map):#: SingleMap):
	assert(single_map.fields.size() == single_map.units.size())
	for i in range(single_map.fields.size()):
		assert(single_map.fields[i].size() == single_map.units[i].size())
	assert(single_map.fields.size() == single_map.buildings.size())
	for i in range(single_map.fields.size()):
		assert(single_map.fields[i].size() == single_map.buildings[i].size())
	assert(single_map.fields.size() == single_map.nature.size())
	for i in range(single_map.fields.size()):
		assert(single_map.fields[i].size() == single_map.nature[i].size())
	return true

static func print_map(array: Array) -> void:
	print("Printed map - size(" + str(array[0].size()) + "," + str(array.size()) + ")")
	for i in range(array.size()):
		var line: String = ""
		if i % 2 == 1:
			line += "  "
		for j in range(array[i].size()):
			line += str(array[i][j]) + "  "
			if array[i][j] < 10 && array[i][j] >= 0:
				line += " "
		print(line)

static func convert_name_to_coordinates(hex_name: String, map_size: Vector2j) -> Vector2j:
	var number = hex_name.trim_prefix(MapCreator.NODE_BASE_NAME).to_int()

	return Vector2j.new(number % map_size.x, number / map_size.x)
