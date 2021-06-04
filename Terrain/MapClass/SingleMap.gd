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


func building_remove_all(coordinates: Vector2j):
	buildings[coordinates.y][coordinates.x].clear()


func unit_remove_all(coordinates: Vector2j):
	units[coordinates.y][coordinates.x] = {}


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
				Resources.add_resources(dict, Buildings.BASIC_RESOURCES_PER_FIELD)

				# Buildings
				for i in buildings[y][x].keys():
					Resources.add_resources(dict, Buildings.get_building_production(i, buildings[y][x][i]["level"]))
					Resources.remove_resources(dict, Buildings.get_building_usage(i, buildings[y][x][i]["level"]))
				# Units - only consume
				for i in units[y][x].keys():
					Resources.remove_resources(dict, Units.get_unit_usage(units[y][x]["type"], units[y][x]["level"]))

	return dict


func add_unit(coordinates: Vector2j, unit: int, level: int) -> void:
	Units.validate_type(unit)
	assert(units[coordinates.y][coordinates.x].empty())  # Jednostka nie może istnieć
	assert(level >= 1 && level <= 3)

	units[coordinates.y][coordinates.x] = {"type": unit, "level": level, "stats": Units.get_default_stats(unit, level)}


func remove_unit(coordinates: Vector2j) -> void:
	assert(!units[coordinates.y][coordinates.x].empty())  # Jednostka musi istnieć
	units[coordinates.y][coordinates.x] = {}


func has_unit(coordinates: Vector2j) -> bool:
	return !units[coordinates.y][coordinates.x].empty()


func get_neighbourhoods(coordinates: Vector2j, player_number: int, _ignore_player_ants: bool = false) -> Array:
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

	var checked_neighbour: Array = []
	for i in neighbour:
		if !_check_if_on_field_is_player_ant(player_number, i):
			checked_neighbour.append(i)
#	for i in neighbour:
#		print(i.to_string())

	return checked_neighbour


func _check_if_on_field_is_player_ant(player_number: int, coordinates: Vector2j) -> bool:
	if !units[coordinates.y][coordinates.x].empty() && fields[coordinates.y][coordinates.x] == player_number:
		return true
	return false


enum FIGHT_RESULTS { ATTACKER_WON_KILLED_ANT, ATTACKER_WON_EMPTY_FIELD, DRAW_BOTH_ANT_LIVE, DRAW_BOTH_ANT_DEAD, DEFENDER_WON }


class FightResult:
	var result: int
	var attacker_defeated: int = 0
	var defender_defeated: int = 0


# TODO nie zapomnieć aby zaktualizować pola(fields) i kolory mrówek i pól
func move_unit(start_c: Vector2j, end_c: Vector2j) -> FightResult:
	assert(fields[start_c.y][start_c.x] != FIELD_TYPE.NO_FIELD)  # Musi istnieć pole mrówki atakującej
	assert(fields[end_c.y][end_c.x] != FIELD_TYPE.NO_FIELD)  # Musi istnieć pole atakowane
	assert(!units[start_c.y][start_c.x].empty())  # Musi istnieć mrówka atakująca
	assert(!(!units[end_c.y][end_c.x].empty() && fields[start_c.y][start_c.x] == fields[end_c.y][end_c.x]))  # Nie można przemiesczać się na pole jeśli pole jest nasze i mrówka też jest nasza
	assert(units[start_c.y][start_c.x]["stats"]["number_of_movement"] > 0)  # Musi mieć mrówka możliwość poruszania

	units[start_c.y][start_c.x]["stats"]["number_of_movement"] -= 1

	var result: FightResult = FightResult.new()

	# Brak Walki
	if units[end_c.y][end_c.x].empty():
		units[end_c.y][end_c.x] = units[start_c.y][start_c.x].duplicate(true)
		units[start_c.y][start_c.x] = {}
		result.result = FIGHT_RESULTS.ATTACKER_WON_EMPTY_FIELD
	# Walka
	else:
		var attacker_stats: Dictionary = units[start_c.y][start_c.x]["stats"].duplicate(true)
		var defender_stats: Dictionary = units[end_c.y][end_c.x]["stats"].duplicate(true)

		if buildings[end_c.y][end_c.x].has(Buildings.TYPES_OF_BUILDINGS.PILE):
			defender_stats["defense"] += 15

		var additional_attack: float = 2.9
		if attacker_stats["ants"] < 10 && defender_stats["ants"] < 10:
			additional_attack *= 5.0
		elif attacker_stats["ants"] < 20 && defender_stats["ants"] < 20:
			additional_attack *= 3.0

		var destroyed_defenders_ants: int = attacker_stats["attack"] * additional_attack * attacker_stats["ants"] * (100 - defender_stats["defense"]) * (randf() * 0.4 + 0.6) / 10000
		var destroyed_attackers_ants: int = defender_stats["attack"] * additional_attack * defender_stats["ants"] * (100 - attacker_stats["defense"]) * (randf() * 0.4 + 0.6) / 10000

		result.attacker_defeated = int(min(attacker_stats["ants"], destroyed_attackers_ants))
		result.defender_defeated = int(min(defender_stats["ants"], destroyed_defenders_ants))

		attacker_stats["ants"] -= destroyed_attackers_ants
		defender_stats["ants"] -= destroyed_defenders_ants

		print("Destroyed attacker ants " + str(destroyed_attackers_ants))
		print("Destroyed defenders ants " + str(destroyed_defenders_ants))

		units[start_c.y][start_c.x]["stats"]["ants"] = max(attacker_stats["ants"], 0)
		units[end_c.y][end_c.x]["stats"]["ants"] = max(defender_stats["ants"], 0)

		if attacker_stats["ants"] <= 0 && defender_stats["ants"] <= 0:
			units[end_c.y][end_c.x] = {}
			units[start_c.y][start_c.x] = {}
			result.result = FIGHT_RESULTS.DRAW_BOTH_ANT_DEAD
		elif attacker_stats["ants"] <= 0 && defender_stats["ants"] > 0:
			units[start_c.y][start_c.x] = {}
			result.result = FIGHT_RESULTS.DEFENDER_WON
		elif attacker_stats["ants"] > 0 && defender_stats["ants"] > 0:
			result.result = FIGHT_RESULTS.DRAW_BOTH_ANT_LIVE
		elif attacker_stats["ants"] > 0 && defender_stats["ants"] <= 0:
			units[end_c.y][end_c.x] = units[start_c.y][start_c.x].duplicate(true)
			units[start_c.y][start_c.x] = {}
			result.result = FIGHT_RESULTS.ATTACKER_WON_KILLED_ANT

	return result
