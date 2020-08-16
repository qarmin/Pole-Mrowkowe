extends Node

### Klasa do tworzenia map, ich populacji oraz środkowania

var SingleHex: PackedScene = load("res://Terrain/SingleHex/SingleHex.tscn")
var Ant: PackedScene = load("res://Units/Ant.tscn")

enum FIELD_TYPE { NO_FIELD = -9, DEFAULT_FIELD = 0, PLAYER_FIRST = 1, PLAYER_LAST = 4 }

#const NO_FIELD : int = -100
#const DEFAULT_FIELD : int = -1
#const FIRST_PLAYER : int = 0

const SINGLE_HEX_DIMENSION: Vector2 = Vector2(1.732, 2)  # Dokładna wartość to (1.7321,2) ale czasami pomiędzy nimi migocze wolna przestrzeń, dlatego należy to nieco zmniejszyć
const NODE_BASE_NAME: String = "SingleHex"
var texture_base: SpatialMaterial
var texture_array: Array = []
var ant_base: SpatialMaterial
var ant_texture_array: Array = []


## Należy na początku zainicjalizować wszystkie potrzebne zmienne
func _ready() -> void:
	# Logika jest ustawiona na to, że wartości są przedstawiane w odpowiedniej kolejności
	assert(FIELD_TYPE.NO_FIELD < FIELD_TYPE.DEFAULT_FIELD)
	assert(FIELD_TYPE.DEFAULT_FIELD < FIELD_TYPE.PLAYER_FIRST)

	randomize()  # Bez tego za każdym razem wychdzą takie same wyniki randi()

	assert(GameSettings.MAX_TEAMS == 4)  # Należy dodać więcej wyglądów

	texture_base = load("res://Terrain/SingleHex/SingleHexBase.tres")
	ant_base = load("res://Units/Outfit/OutfitBase.tres")

	for i in range(0, GameSettings.MAX_TEAMS):
		texture_array.append(load("res://Terrain/SingleHex/SingleHexTEAM" + str(i + 1) + ".tres"))
		ant_texture_array.append(load("res://Units/Outfit/OutfitTEAM" + str(i + 1) + ".tres"))


## Tworzy mapę i zapisuje ją do tablicy single_map.fields z listą wszystkich pól
func create_map(single_map: SingleMap, hex_number: Vector2j, chance_to_terrain: int) -> void:
	assert(! is_instance_valid(single_map.map))
	assert(hex_number.x > 0 && hex_number.y > 0)
	assert(hex_number.x * hex_number.y >= 4)
	assert(chance_to_terrain > 0 && chance_to_terrain < 101)

	single_map.set_size(hex_number)
	if chance_to_terrain == 100:  # Tworzy pełną mapę
		single_map.initialize_fields(MapCreator.FIELD_TYPE.DEFAULT_FIELD)
		single_map.calculate_number_of_terrains()
		return

	single_map.initialize_fields(MapCreator.FIELD_TYPE.NO_FIELD)

	var to_check: Array = []
	var checked: Array = []
	var current_element: Vector2j = Vector2j.new(0, 0)

	while true:
		# Resetowanie tablicy
		for x in range(hex_number.x):
			for y in range(hex_number.y):
				single_map.fields[y][x] = MapCreator.FIELD_TYPE.NO_FIELD

		## Wybrany ląd (0,0) - ma to wiele plusów
		## Przy przycinaniu trzeba mieć na uwadzę jedynie maksymalny x oraz y
		## W przyszłości nie trzeba będzie brać pod uwagę możliwości, że hexy będą rozpoczynały się od linii parzystej
		## przez co obliczenia będą uproszczone
		single_map.fields[0][0] = FIELD_TYPE.DEFAULT_FIELD
		to_check.append(Vector2j.new(0, 0))

		#SingleMap.print_map(single_map.fields)
		while to_check.size() > 0:
			current_element = to_check.pop_front()

			#print("Sprawdzam teraz punkt " + str(current_element.x) + " " + str(current_element.y))
			assert(single_map.fields[current_element.y][current_element.x] == MapCreator.FIELD_TYPE.DEFAULT_FIELD)
			assert(current_element.x < hex_number.x && current_element.x >= 0)
			assert(current_element.y < hex_number.y && current_element.y >= 0)

			var help_array = [[[0, -1], [1, -1], [-1, 0], [1, 0], [0, 1], [1, 1]], [[-1, -1], [0, -1], [-1, 0], [1, 0], [-1, 1], [0, 1]]]

			for h in [0, 1]:
				if current_element.y % 2 == ((h + 1) % 2):
					for i in range(6):
						if (
							(current_element.x + help_array[h][i][0] >= 0)
							&& (current_element.x + help_array[h][i][0] < hex_number.x)
							&& (current_element.y + help_array[h][i][1] >= 0)
							&& (current_element.y + help_array[h][i][1] < hex_number.y)
						):
							var cep_x = current_element.x + help_array[h][i][0]
							var cep_y = current_element.y + help_array[h][i][1]
							if ! Vector2j.is_in_array(checked, Vector2j.new(cep_x, cep_y)) && ! Vector2j.is_in_array(to_check, Vector2j.new(cep_x, cep_y)):
								assert(single_map.fields[cep_y][cep_x] == MapCreator.FIELD_TYPE.NO_FIELD)
								var is_terrain: bool = randi() % 100 < chance_to_terrain
								if is_terrain:
									single_map.fields[cep_y][cep_x] = MapCreator.FIELD_TYPE.DEFAULT_FIELD
									to_check.append(Vector2j.new(cep_x, cep_y))
								else:
									single_map.fields[cep_y][cep_x] = MapCreator.FIELD_TYPE.NO_FIELD
									checked.append(Vector2j.new(cep_x, cep_y))

			#SingleMap.print_map(single_map.fields)
			for i in to_check:
				assert(single_map.fields[i.y][i.x] == MapCreator.FIELD_TYPE.DEFAULT_FIELD)

			assert(! Vector2j.is_in_array(checked, current_element))

			checked.append(current_element)

		# Jeśli wygenerowano stanowczo za mało hexów, to powtarzamy ich tworzenie
		single_map.calculate_number_of_terrains()

# warning-ignore:narrowing_conversion
		var needed_hexes: int = max(2, hex_number.x * hex_number.y * (pow(chance_to_terrain / 100.0, 3) * 0.75))

		if single_map.number_of_terrain >= needed_hexes:
			break

#		print("Nie udało mi się stworzyć poprawnego algorytmu - Wyznaczyłem " + str(single_map.number_of_terrain) + " a potrzebne było " + str(needed_hexes))
		#	SingleMap.print_map(array)
		to_check.clear()
		checked.clear()

	single_map.shrink_map()
	return


func populate_map_realistically(single_map: SingleMap, number_of_players: int = GameSettings.MAX_TEAMS, max_number_of_additional_terrains: int = 0) -> bool:
#	assert(number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS)
#	assert(single_map.number_of_terrain > number_of_players)
	assert(max_number_of_additional_terrains >= 0)

	if not (number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS):
#		print("Nieprawidłowa liczba graczy - " + str(number_of_players))
		return false
	if not (single_map.number_of_terrain > number_of_players):
#		print("Liczba terenów " + str(single_map.number_of_terrain) + ", musi być większa niż liczba graczy - " + str(number_of_players))
		return false

	var temp_fields: Array
	var curr: Vector2j = Vector2j.new(0, 0)

	# Wybieranie miejsca dla pierwszego gracza
	while true:
		curr.x = randi() % single_map.size.x
		curr.y = randi() % single_map.size.y
		if single_map.fields[curr.y][curr.x] == FIELD_TYPE.DEFAULT_FIELD:
			single_map.players.append(curr)
			break

	# Wybieranie miejsc dla innych graczy
	while single_map.players.size() < number_of_players:
		temp_fields = pm_fully_create_distance_array(single_map.fields, single_map.players)
		single_map.players.append(pm_fully_choose_point_from_distance_array(temp_fields, single_map.number_of_terrain, number_of_players))

	# Narysowanie głównego miejsca dla każdego z osób/przeciwników

	for i in range(single_map.players.size()):
		single_map.fields[single_map.players[i].y][single_map.players[i].x] = FIELD_TYPE.PLAYER_FIRST + i

	# Ustawienie tyle ile się da pól obok, ile tylko się da
#	var terrain_to_check : Array = []
#	var terrain_checked : Array = []
	# TODO - Dodać określoną liczbę początkową pól(nie wiem jak do końca to zaimplementować), póki co jest jedno pole dla każdego gracza.
#	while(max_number_of_additional_terrains > 0):
#		for i in range(single_map.players.size()):
#
#
#
#			pass
#		max_number_of_additional_terrains -= 1
	# TODO - Dodać podstawowe budynki do mapy podczas tworzeni - np. główne mrowisko

#	## START PRINT MAP
#	SingleMap.print_map(single_map.fields)
#
#	for i in single_map.players:
#		single_map.fields[i.y][i.x] = 88

#	SingleMap.print_map(single_map.fields)
#	## END PRINT MAP
	return true


## Dowolnie wypełnia pola mrówkami oraz kolorami
func populate_map_randomly(single_map: SingleMap, ant_chance: int = 100, number_of_players: int = GameSettings.MAX_TEAMS) -> bool:
	assert(number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS)
	assert(ant_chance >= 0 && ant_chance < 101)
	assert(single_map.size.x * single_map.size.y >= 4)
	assert(single_map.size.x > 0 && single_map.size.y > 0)

	if not (number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS):
		return false
	if not (ant_chance >= 0 && ant_chance < 101):
		return false
	if not (single_map.size.x * single_map.size.y >= 2):
		return false
	if not (single_map.size.x > 0 && single_map.size.y > 0):
		return false

	var choosen_player: int

	for y in range(single_map.size.y):
		for x in range(single_map.size.x):
			if single_map.fields[y][x] == MapCreator.FIELD_TYPE.DEFAULT_FIELD:
				choosen_player = randi() % (number_of_players + 1) - 1

				if choosen_player != -1:
					single_map.fields[y][x] = MapCreator.FIELD_TYPE.PLAYER_FIRST + choosen_player

				if randi() % 100 < ant_chance:
					single_map.units[y][x] = randi() % (Units.TYPES_OF_ANTS.ANT_MAX - Units.TYPES_OF_ANTS.ANT_MIN) + Units.TYPES_OF_ANTS.ANT_MIN

	return true


func pm_fully_create_distance_array(fields: Array, players: Array) -> Array:
	var smallest_array: Array = []  # Tablica z najmniejszymi odległościami od 
	var current_element: Vector2j = Vector2j.new(0, 0)
	var current_value: int = 0

	for i in range(fields.size()):
		smallest_array.append([])
		for _j in range(fields[i].size()):
			smallest_array[i].append(-1)

	var checked: Array = []
	var to_check: Array = []
	var to_check_value: Array = []

	for r in players:
		to_check.append(r)
		to_check_value.append(0)
		smallest_array[r.y][r.x] = 0

		while to_check.size() > 0:
			current_element = to_check.pop_front()
			current_value = to_check_value.pop_front()

			#print("Sprawdzam teraz punkt " + str(current_element.x) + " " + str(current_element.y))

			var help_array = [[[0, -1], [1, -1], [-1, 0], [1, 0], [0, 1], [1, 1]], [[-1, -1], [0, -1], [-1, 0], [1, 0], [-1, 1], [0, 1]]]

			for h in [0, 1]:
				if current_element.y % 2 == ((h + 1) % 2):
					for i in range(6):
						if (
							(current_element.x + help_array[h][i][0] >= 0)
							&& (current_element.x + help_array[h][i][0] < smallest_array[0].size())
							&& (current_element.y + help_array[h][i][1] >= 0)
							&& (current_element.y + help_array[h][i][1] < smallest_array.size())
						):
							var cep_x = current_element.x + help_array[h][i][0]
							var cep_y = current_element.y + help_array[h][i][1]
							if ! Vector2j.is_in_array(checked, Vector2j.new(cep_x, cep_y)) && ! Vector2j.is_in_array(to_check, Vector2j.new(cep_x, cep_y)):
								if fields[cep_y][cep_x] == FIELD_TYPE.DEFAULT_FIELD:
									if smallest_array[cep_y][cep_x] == -1 || smallest_array[cep_y][cep_x] > current_value:
										smallest_array[cep_y][cep_x] = current_value + 1
										to_check.append(Vector2j.new(cep_x, cep_y))
										to_check_value.append(current_value + 1)

			assert(! Vector2j.is_in_array(checked, current_element))

			checked.append(current_element)
		checked = []
		to_check = []
		to_check_value = []

	return smallest_array


func pm_fully_choose_point_from_distance_array(array: Array, number_of_terrain: int, number_of_players: int) -> Vector2j:
	var biggest_numbers: Array = []
	var biggest_number: int
	var biggest_vector: Vector2j

	#for _z in range(1):
# warning-ignore:integer_division
	for _z in range(0, int(number_of_terrain / (number_of_players + 1))):
		biggest_vector = Vector2j.new(-1, -1)
		biggest_number = -1
		for y in range(array.size()):
			for x in range(array[y].size()):
				if array[y][x] > biggest_number:
					biggest_number = array[y][x]
					biggest_vector = Vector2j.new(x, y)
		if biggest_number != 0:
			biggest_numbers.append(biggest_vector)
			array[biggest_vector.y][biggest_vector.x] = -1
		else:
			break

	if biggest_numbers.size() == 0:
		# TODO - To może się zdarzyć gdy liczba graczy jest równa liczbie terenów
		assert(false)
		return Vector2j.new(0, 0)

	return biggest_numbers[randi() % biggest_numbers.size()]


func serialize_map(_single_map: SingleMap) -> void:
	push_warning("TODO - Serializacja mapy")


func deserialize_map() -> void:
	push_warning("TODO - Wczytywanie mapy z pliku i jej tworzenie")


func populate_map_buildings(_single_map: SingleMap) -> void:
	push_warning("TODO - Tworzenie głównej siedziby i być może jakichś podstawowych budynków, może być przydatne przy tworzeniu mapy")


## Zapisuje mapę do pliku jako PackedScene
## Dostępne jest to tylko do celów testowych
func save_map_as_packed_scene(single_map: SingleMap, destroy: bool = false) -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(single_map.map)

	if ResourceSaver.save("res://GeneratedMap.tscn", packed_scene) != OK:
		printerr("Nie powiodła się próba zapisu mapy")

	if destroy == true:
		single_map.map.queue_free()


#	var packed_scene = PackedScene.new()
#	packed_scene.pack(map)
#	if(ResourceSaver.save("user://GeneratedMap.tscn", packed_scene) != OK):

#	if(ResourceSaver.save("res://GeneratedMap.tscn", packed_scene) != OK):
#		printerr("Nie powiodła się próba zapisu mapy")
#
#	map.queue_free()


func save_map_as_text(single_map: SingleMap) -> void:
	var file_to_save: File = File.new()
	if file_to_save.open("saved_slot1.txt", File.WRITE) != OK:
		push_error("Nie udało się utworzyć pliku do zapisu")

	file_to_save.store_8(1)  # Wersja savu, może być przydatna przy wczytywaniu

	file_to_save.store_var(single_map.size)
	file_to_save.store_var(single_map.fields)
	file_to_save.store_var(single_map.units)

	file_to_save.close()
	pass


## Tworzy mapę, którą można użyć w Scene Tree(Jest to zwykły Node)
func create_3d_map(single_map: SingleMap) -> void:
	var map: Spatial = Spatial.new()
	map.set_name("Map")

	for y in single_map.size.y:
		for x in single_map.size.x:
			if single_map.fields[y][x] != FIELD_TYPE.NO_FIELD:
				var SH: MeshInstance = SingleHex.instance()
				SH.translation = Vector3(x * SINGLE_HEX_DIMENSION.x, randf(), y * SINGLE_HEX_DIMENSION.y * 0.75)
				if y % 2 == 1:
					SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x, 0, 0)
				SH.set_name(NODE_BASE_NAME + str(y * single_map.size.x + x))

				if single_map.fields[y][x] == FIELD_TYPE.DEFAULT_FIELD:
					SH.set_surface_material(0, texture_base)
				else:
					SH.set_surface_material(0, texture_array[single_map.fields[y][x] - MapCreator.FIELD_TYPE.PLAYER_FIRST])
				map.add_child(SH)
				SH.set_owner(map)

	single_map.set_map(map)

	# Po wygenerowaniu mapy ładnie ją wycentrowujemy
	center_map(single_map)
	pass


## Dokładnie centruje mapę
func center_map(single_map: SingleMap) -> void:
	assert(single_map.size.x > 0 && single_map.size.y > 0)
	var real_map_size: Vector2 = Vector2()

	real_map_size.x = single_map.size.x * SINGLE_HEX_DIMENSION.x
	## Gdy w parzystej linii na końcu jest obecny hex, to wtedy wymiary mapy są większe niż zazwyczaj
	for y in range(1, single_map.size.y, 2):
		if single_map.fields[y][single_map.size.x - 1] != FIELD_TYPE.NO_FIELD:
			real_map_size.x += SINGLE_HEX_DIMENSION.x / 2.0
			break

	real_map_size.y = SINGLE_HEX_DIMENSION.y * 0.25 + single_map.size.y * (SINGLE_HEX_DIMENSION.y * 0.75)

	# Mapa początkowo jest już przesunięta tak aby wskazywała na środek pierwszego hexa, dlatego należy to skoregować
	single_map.map.translation.x -= (real_map_size.x - SINGLE_HEX_DIMENSION.x) / 2.0
	single_map.map.translation.z -= (real_map_size.y - SINGLE_HEX_DIMENSION.y) / 2.0
