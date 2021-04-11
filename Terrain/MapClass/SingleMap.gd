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
var PLAAAYERS : Array
var buildings: Array  # Tablica z budynkami [y][x]{z} 
var real_map_size: Vector3  # Rzeczywista wielkość mapy

## Zmienne sprawdzające czy dla danej mapy była wykonywana dana operacja, przydatne tylko do debugowania
var was_resetted: bool = false
var was_shrinked: bool = false

enum FIELD_TYPE { NO_FIELD = -9, DEFAULT_FIELD = -1, PLAYER_FIRST = 0, PLAYER_LAST = 3 }

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
			units[y].append(Units.TYPES_OF_ANTS.NO_UNIT)
			buildings[y].append({})
			nature[y].append(Terrain.TYPES_OF_HEX.NORMAL)
	assert(fields.size() == units.size())
	assert(fields.size() == buildings.size())


## Oblicza liczbę terenów na mapie
## Należy ją wykonać po ustawieniu tablicy fields
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
	assert(hex_name.begins_with(MapCreator.NODE_BASE_NAME))
	var number = hex_name.trim_prefix(MapCreator.NODE_BASE_NAME).to_int()

	return Vector2j.new(number % map_size.x, number / map_size.x)

# Return owner of specific field
func get_field_owner(coordinates : Vector2j) -> int:
	return fields[coordinates.y][coordinates.x]

func get_place_for_build(coordinates : Vector2j) -> int:
	var builds : Dictionary = buildings[coordinates.y][coordinates.x]
	var available_places : Array = [0,1,2,3]
	for building in builds.values():
		available_places.erase(building["place"])
	if available_places.size() > 0:
		return available_places[0]
	return -1

# TODO Dodać funkcję/lub zmienić np. add_building aby zwracała koordynaty budynku(Transform albo Vector3) w zależności od położenia

func get_place_where_is_building(coordinates : Vector2j, building : int) -> Vector3:
	Buildings.validate_building(building)
	assert(buildings[coordinates.y][coordinates.x].has(building)) # Budynek musi istnieć
	
	var place : int = buildings[coordinates.y][coordinates.x][building]["place"]
	
	if place == 0:
		return Vector3(0,0,-0.522)
	elif place == 1:
		return Vector3(-0.522,0,0)
	elif place == 2:
		return Vector3(0,0,0.522)
	else:
		return Vector3(0.522,0,0)

func add_building(coordinates : Vector2j, building : int , level : int = 1) -> void:
	Buildings.validate_building(building)
	assert(!buildings[coordinates.y][coordinates.x].has(building)) # Budynek nie może istnieć
	var place : int = get_place_for_build(coordinates)
	assert(place != -1) # Musi mieć miejsce na budowę, tę funkcję można tylko wywołać gdy jesteśmy pewni że coś tu może powstać

	buildings[coordinates.y][coordinates.x][building] = {"level" : level, "place" : place}
	
func remove_building(coordinates : Vector2j, building : int , level : int = 1) -> void:
	Buildings.validate_building(building)
	assert(buildings[coordinates.y][coordinates.x].has(building)) # Budynek musi istnieć
	
	buildings[coordinates.y][coordinates.x][building] = level
	
func calculate_user_resources(player_number) -> Dictionary:
	# TODO Not tested
	var dict = Resources.get_resources()
	
	# Buildings
	for y in range(size.y):
		for x in range(size.x):
			if fields[y][x] == player_number:
				print(buildings[y][x])
				
	
	return dict

# Return true if happened underflow of resources
func add_resources(base_dict : Dictionary, to_add_dict : Dictionary) -> bool:
	var underflow : bool = false
	
	for key in base_dict.keys():
		base_dict[key] += to_add_dict[key]
		
		if base_dict[key] < 0:
			base_dict[key] = 0
			underflow = true
			 
	
	return underflow
