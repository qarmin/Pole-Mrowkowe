class_name SingleMap

var map: Spatial = null
var size: Vector2j = Vector2j.new(0, 0)
var fields: Array = []  # Dwuwymiarowa tablica z zaznaczonymi polami, gdzie które się znajduje, tak aby nie trzeba było cały czas sięgać po tablicę
var units: Array = []
var nature: Array = []  # TODO, pola mogą mieć różne właściwości
var preview: Image = Image.new()
var number_of_terrain: int = 0
var number_of_all_possible_hexes: int = 0
var players: Array = []  # Pozycje bazowe na mapie, nie wiem do końca do czego mogłoby się to przydać, ale może być przydatne do stawiania początkowej bazy
var PLAAAYERS: Array = []
var buildings: Array = []  # Tablica z budynkami [y][x]{z}
var real_map_size: Vector3 = Vector3()  # Rzeczywista wielkość mapy

## Zmienne sprawdzające czy dla danej mapy była wykonywana dana operacja, przydatne tylko do debugowania
var was_resetted: bool = false
var was_shrinked: bool = false

enum FIELD_TYPE { NO_FIELD = -9, DEFAULT_FIELD = -1, PLAYER_FIRST = 0, PLAYER_LAST = 3 }  # PLAYER_FIRST ma być zawsze równy 0, bo zależy od tego wiele różnych rzeczy, które nie są opisane


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
	assert(type_of_field == FIELD_TYPE.DEFAULT_FIELD or type_of_field == FIELD_TYPE.NO_FIELD)
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
			units[y].append({})
			buildings[y].append({})
			nature[y].append(Terrain.TYPES_OF_HEX.NORMAL)
	assert(fields.size() == units.size())
	assert(fields.size() == buildings.size())


## Oblicza liczbę terenów na mapie
## Należy ją wykonać po zakończeniu wypełniania tablicy fields
func calculate_number_of_terrains():
	number_of_terrain = 0
	for y in range(size.y):
		for x in range(size.x):
			if fields[y][x] != FIELD_TYPE.NO_FIELD:
				number_of_terrain += 1


## Odpowiada za przycięcie mapy jeśli nie została nie ma wymiarów zakładanych przez gracza
func shrink_map() -> void:
	var real_max_x: int = -1
	var real_max_y: int = -1

#	print_map(fields)
	for y in size.y:
		for x in size.x:
			if fields[y][x] != FIELD_TYPE.NO_FIELD:
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

# Po prostu sprawdza wymiary tablic, potrzebne tylko do debugowania
static func validate_sizes_of_arrays(single_map):  #: SingleMap):
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
	assert(hex_name.begins_with(MapCreator.NODE_BASE_NAME))
	var number = hex_name.trim_prefix(MapCreator.NODE_BASE_NAME).to_int()

	return Vector2j.new(number % map_size.x, number / map_size.x)

static func convert_coordinates_to_name(coordinates: Vector2j, map_size: Vector2j) -> String:
	return MapCreator.NODE_BASE_NAME + str(coordinates.y * map_size.x + coordinates.x)


# Return owner of specific field
func get_field_owner(coordinates: Vector2j) -> int:
	return fields[coordinates.y][coordinates.x]


func building_get_place_for_build(coordinates: Vector2j) -> int:
	var builds: Dictionary = buildings[coordinates.y][coordinates.x]
	var available_places: Array = [0, 1, 2, 3]
	for building in builds.values():
		available_places.erase(building["place"])
	if available_places.size() > 0:
		return available_places[0]
	return -1


# TODO Dodać funkcję/lub zmienić np. building_add aby zwracała koordynaty budynku(Transform albo Vector3) w zależności od położenia


func building_get_place_where_is_building(coordinates: Vector2j, building: int) -> Vector3:
	Buildings.validate_building(building)
	assert(buildings[coordinates.y][coordinates.x].has(building))  # Budynek musi istnieć

	var place: int = buildings[coordinates.y][coordinates.x][building]["place"]

	if place == 0:
		return Vector3(0, 0, -0.522)
	elif place == 1:
		return Vector3(-0.522, 0, 0)
	elif place == 2:
		return Vector3(0, 0, 0.522)
	else:
		return Vector3(0.522, 0, 0)


func building_is_built(coordinates: Vector2j, building: int) -> bool:
	return buildings[coordinates.y][coordinates.x].has(building)


func building_add(coordinates: Vector2j, building: int, level: int = 1) -> void:
	Buildings.validate_building(building)
	assert(!buildings[coordinates.y][coordinates.x].has(building))  # Budynek nie może istnieć
	var place: int = building_get_place_for_build(coordinates)
	assert(place != -1)  # Musi mieć miejsce na budowę, tę funkcję można tylko wywołać gdy jesteśmy pewni że coś tu może powstać

	buildings[coordinates.y][coordinates.x][building] = {"level": level, "place": place}


func building_remove(coordinates: Vector2j, building: int) -> void:
	Buildings.validate_building(building)
	assert(buildings[coordinates.y][coordinates.x].has(building))  # Budynek musi istnieć

	assert(buildings[coordinates.y][coordinates.x].erase(building))


func building_change_level(coordinates: Vector2j, building: int, level: int) -> void:
	Buildings.validate_building(building)
	assert(buildings[coordinates.y][coordinates.x].has(building))  # Budynek musi istnieć
	assert(level >= 1 && level <= 3)
	assert(buildings[coordinates.y][coordinates.x][building]["level"] != level)  # Nie można zmienić levela na tę samą wersję

	buildings[coordinates.y][coordinates.x][building]["level"] = level


func building_get_level(coordinates: Vector2j, building: int) -> int:
	Buildings.validate_building(building)
	return buildings[coordinates.y][coordinates.x][building]["level"]


# Used to calculate end turn resources change, it don't change
func calculate_end_turn_resources_change(player_number) -> Dictionary:
	var dict = Resources.get_resources()

	for y in range(size.y):
		for x in range(size.x):
			if fields[y][x] == player_number:
				# Adds basic fields
				Resources.add_resources(dict, Buildings.BASIC_RESOURCES_PER_FIELD,true)

				# Buildings
				for i in buildings[y][x].keys():
					Resources.add_resources(dict, Buildings.get_building_production(i, buildings[y][x][i]["level"]),true)
					Resources.add_resources(dict, Buildings.get_building_usage(i, buildings[y][x][i]["level"]),false)
				# Units - only consume 
				for i in units[y][x].keys():
					Resources.add_resources(dict, Units.get_unit_usage(units[y][x]["type"],units[y][x]["level"]),false)

	return dict


func add_unit(coordinates: Vector2j, unit: int, level: int) -> void:
	Units.validate_type(unit)
	assert(units[coordinates.y][coordinates.x].empty())  # Jednostka nie może istnieć
	assert(level >= 1 && level <= 3)

	units[coordinates.y][coordinates.x] = {"type": unit, "level": level}


func remove_unit(coordinates: Vector2j) -> void:
	assert(!units[coordinates.y][coordinates.x].empty())  # Jednostka musi istnieć
	units[coordinates.y][coordinates.x] = {}


func has_unit(coordinates: Vector2j) -> bool:
	return !units[coordinates.y][coordinates.x].empty()


func move_unit(from: Vector2j, to: Vector2j) -> void:
	assert(!units[from.y][from.x].empty())
	assert(units[to.y][to.x].empty())
	units[to.y][to.x] = units[from.y][from.x]
	units[from.y][from.x] = {}


func get_neighbourhoods(coordinates: Vector2j, _player_number: int, _ignore_player_ants: bool = false) -> Array:
	var neighbour: Array = []

	if coordinates.x > 0:  # Left
		if fields[coordinates.y][coordinates.x - 1] != FIELD_TYPE.NO_FIELD:
			neighbour.append(Vector2j.new(coordinates.x - 1, coordinates.y))
	if coordinates.x < size.x - 1:  # Right
		if fields[coordinates.y][coordinates.x + 1] != FIELD_TYPE.NO_FIELD:
			neighbour.append(Vector2j.new(coordinates.x + 1, coordinates.y))

	if coordinates.y % 2 == 0:
		if coordinates.x > 0 && coordinates.y > 0:  # Left Upper
			if fields[coordinates.y - 1][coordinates.x - 1] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x - 1, coordinates.y - 1))
		if coordinates.x > 0 && coordinates.y < size.y - 1:  # Left Down
			if fields[coordinates.y + 1][coordinates.x - 1] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x - 1, coordinates.y + 1))

		if coordinates.y > 0:  # Right Upper
			if fields[coordinates.y - 1][coordinates.x] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x, coordinates.y - 1))
		if coordinates.y < size.y - 1:  # Right Down
			if fields[coordinates.y + 1][coordinates.x] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x, coordinates.y + 1))
	else:
		if coordinates.y > 0:  # Left Upper
			if fields[coordinates.y - 1][coordinates.x] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x, coordinates.y - 1))
		if coordinates.y < size.y - 1:  # Left Down
			if fields[coordinates.y + 1][coordinates.x] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x, coordinates.y + 1))

		if coordinates.x < size.x - 1 && coordinates.y > 0:  # Right Upper
			if fields[coordinates.y - 1][coordinates.x + 1] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x + 1, coordinates.y - 1))
		if coordinates.x < size.x - 1 && coordinates.y < size.y - 1:  # Right Down
			if fields[coordinates.y + 1][coordinates.x + 1] != FIELD_TYPE.NO_FIELD:
				neighbour.append(Vector2j.new(coordinates.x + 1, coordinates.y + 1))

#	for i in neighbour:
#		print(i.to_string())

	return neighbour
