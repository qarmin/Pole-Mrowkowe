extends Node

### Klasa do tworzenia map, ich populacji oraz środkowania

var SingleHex: PackedScene = load("res://Terrain/SingleHex/SingleHex.tscn")

var AntWorker: PackedScene = load("res://Units/Types/Worker/Worker.tscn")
var AntSoldier: PackedScene = load("res://Units/Types/Soldier/Soldier.tscn")
var AntFlying: PackedScene = load("res://Units/Types/Flying/Flying.tscn")

var AntsArray: Array = [AntWorker, AntSoldier, AntFlying]

# Buildings
var Anthill: PackedScene = load("res://Models/Buildings/Anthill/Anthill.tscn")
var Farm: PackedScene = load("res://Models/Buildings/Farm/Farm.tscn")
var Sawmill: PackedScene = load("res://Models/Buildings/Sawmill/Sawmill.tscn")
var Barracks: PackedScene = load("res://Models/Buildings/Barracks/Barracks.tscn")
var Piles: PackedScene = load("res://Models/Buildings/Piles/Piles.tscn")
var GoldMine: PackedScene = load("res://Models/Buildings/GoldMine/GoldMine.tscn")

const SINGLE_HEX_DIMENSION: Vector2 = Vector2(1.732, 2)  # Dokładna wartość to (1.7321,2) ale czasami pomiędzy nimi migocze wolna przestrzeń, dlatego należy to nieco zmniejszyć
const NODE_BASE_NAME: String = "SingleHex"
var texture_base: SpatialMaterial
var texture_array: Array = []
var ant_base: SpatialMaterial
var ant_texture_array: Array = []


## Należy na początku zainicjalizować wszystkie potrzebne zmienne
func _ready() -> void:
	# Logika jest ustawiona na to, że wartości są przedstawiane w odpowiedniej kolejności
	assert(SingleMap.FIELD_TYPE.NO_FIELD < SingleMap.FIELD_TYPE.DEFAULT_FIELD)
	assert(SingleMap.FIELD_TYPE.DEFAULT_FIELD < SingleMap.FIELD_TYPE.PLAYER_FIRST)

	randomize()  # Bez tego za każdym razem wychdzą takie same wyniki randi()

	assert(GameSettings.MAX_TEAMS == 4)  # Należy dodać więcej wyglądów jeśli liczba jest inna

	texture_base = load("res://Terrain/SingleHex/SingleHexBase.tres")
	ant_base = load("res://Units/Outfit/OutfitBase.tres")

	for i in range(0, GameSettings.MAX_TEAMS):
		texture_array.append(load("res://Terrain/SingleHex/SingleHexTEAM" + str(i + 1) + ".tres"))
		ant_texture_array.append(load("res://Units/Outfit/OutfitTEAM" + str(i + 1) + ".tres"))


## Tworzy mapę i zapisuje ją do tablicy single_map.fields z listą wszystkich pól, na końcu ją przycina  jeśli potrzeba
func create_map(single_map: SingleMap, hex_number: Vector2j, chance_to_terrain: int) -> void:
	assert(!is_instance_valid(single_map.map))
	assert(hex_number.x > 0 && hex_number.y > 0)
	assert(hex_number.x * hex_number.y >= 5)
	assert(chance_to_terrain > 0 && chance_to_terrain < 6)  # 1-5 zakres
	single_map.reset()
	single_map.set_size(hex_number)
	if chance_to_terrain == 5:  # Tworzy pełną mapę
		single_map.initialize_fields(SingleMap.FIELD_TYPE.DEFAULT_FIELD)
		single_map.calculate_number_of_terrains()
		return

	single_map.initialize_fields(SingleMap.FIELD_TYPE.NO_FIELD)

	var to_check: Array = []
	var checked: Array = []
	var current_element: Vector2j = Vector2j.new(0, 0)

	# Resetowanie tablicy
	for x in range(hex_number.x):
		for y in range(hex_number.y):
			single_map.fields[y][x] = SingleMap.FIELD_TYPE.NO_FIELD

	## Wybrany ląd (0,0) - ma to wiele plusów
	## Przy przycinaniu trzeba mieć na uwadzę jedynie maksymalny x oraz y
	## W przyszłości nie trzeba będzie brać pod uwagę możliwości, że hexy będą rozpoczynały się od linii parzystej
	## przez co obliczenia będą uproszczone
	single_map.fields[0][0] = SingleMap.FIELD_TYPE.DEFAULT_FIELD
	to_check.append(Vector2j.new(0, 0))

	# Zmienna określająca czy za pierwszym razem powiodło się tworzenie mapy.
	# Za piewszym razem
	var second_try: bool = false

	# Liczba potrzebnych hexów, aby mapa mogła zostać uznana za grywalną
	# Liczba 5 określa liczbę maksymalną graczy + 1(wymagane jest to przez inny algorytm)
# warning-ignore:narrowing_conversion
	var needed_hexes: int = max(5, hex_number.x * hex_number.y * pow(chance_to_terrain / 5.0, 2))

	# Zlicza ile terenów zostało
	# Punkt (0,0) jest już dodany
	var number_of_terrains: int = 1

	while true:
		#SingleMap.print_map(single_map.fields)
		while to_check.size() > 0:
			current_element = to_check.pop_front()

			#print("Sprawdzam teraz punkt " + str(current_element.x) + " " + str(current_element.y))
			assert(single_map.fields[current_element.y][current_element.x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD)
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
							if second_try && number_of_terrains >= needed_hexes:
								# Znaleziono wystarczająco hexów, więc można przerwać sprawdzanie
								to_check.clear()
								break
							var cep_x = current_element.x + help_array[h][i][0]
							var cep_y = current_element.y + help_array[h][i][1]
							if !Vector2j.is_in_array(checked, Vector2j.new(cep_x, cep_y)) && !Vector2j.is_in_array(to_check, Vector2j.new(cep_x, cep_y)):
								assert(single_map.fields[cep_y][cep_x] == SingleMap.FIELD_TYPE.NO_FIELD)
								var is_terrain: bool = randi() % 5 < chance_to_terrain
								if is_terrain:
									single_map.fields[cep_y][cep_x] = SingleMap.FIELD_TYPE.DEFAULT_FIELD
									to_check.append(Vector2j.new(cep_x, cep_y))
									number_of_terrains += 1
								else:
									single_map.fields[cep_y][cep_x] = SingleMap.FIELD_TYPE.NO_FIELD
									checked.append(Vector2j.new(cep_x, cep_y))

			# Sprawdzenie czy przypadkiem nie chcę uznać pola pustego jako pola do przypsania mu sąsiada
			for i in to_check:
				assert(single_map.fields[i.y][i.x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD)

			assert(!Vector2j.is_in_array(checked, current_element))

			checked.append(current_element)

		# Jeśli wygenerowano stanowczo za mało hexów, to powtarzamy ich tworzenie
		# lecz tym razem przerywamy gdy ich liczba jest równa 0
		if number_of_terrains >= needed_hexes:
			break

		# Czyścimy tablice
		to_check.clear()
		checked.clear()

#		print("Nie udało mi się stworzyć poprawnego algorytmu - Wyznaczyłem " + str(number_of_terrains) + " a potrzebne było " + str(needed_hexes))
#		SingleMap.print_map(single_map.fields)

		# Od nowa określa, że trzeba znaleźć wszystkich sąsiadów terenów, które
		# aktualnie są już obecne
		for x in range(hex_number.x):
			for y in range(hex_number.y):
				if single_map.fields[y][x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
					to_check.append(Vector2j.new(x, y))

	single_map.calculate_number_of_terrains()
	single_map.shrink_map()
	return


## Wypełnia mapy w przydatny, określony z góry sposób który jest zwykle używany w grach
func populate_map_realistically(single_map: SingleMap, number_of_players: int = GameSettings.MAX_TEAMS, max_number_of_additional_terrains: int = 0) -> void:
	assert(number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS)
	assert(single_map.number_of_terrain > number_of_players)  # Must be greater, not equal because algorithms works in that way
	assert(max_number_of_additional_terrains >= 0)

	var temp_fields: Array
	var curr: Vector2j = Vector2j.new(0, 0)

	# Wybieranie miejsca dla pierwszego gracza
	while true:
		curr.x = randi() % single_map.size.x
		curr.y = randi() % single_map.size.y
		if single_map.fields[curr.y][curr.x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
			single_map.players.append(curr)
			break

	# Wybieranie miejsc dla innych graczy
	# TODO Sprawdzić, czy można to zaimplementować lepiej bez każdorazowej regeneracji tablicy
	while single_map.players.size() < number_of_players:
		temp_fields = pm_fully_create_distance_array(single_map.fields, single_map.players)
		single_map.players.append(pm_fully_choose_point_from_distance_array(temp_fields, single_map.number_of_terrain, number_of_players))

	# Dorysowanie do mapy miejsc w których znajdują się bazy graczy
	for i in range(single_map.players.size()):
		single_map.fields[single_map.players[i].y][single_map.players[i].x] = SingleMap.FIELD_TYPE.PLAYER_FIRST + i

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

	populate_map_buildings(single_map)


## Dowolnie wypełnia pola mrówkami, kolorami oraz budynkami
func populate_map_randomly(single_map: SingleMap, ant_chance: int = 100, number_of_players: int = GameSettings.MAX_TEAMS) -> void:
	assert(number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS)
	assert(ant_chance >= 0 && ant_chance < 101)
	assert(single_map.size.x * single_map.size.y >= 4)
	assert(single_map.size.x > 0 && single_map.size.y > 0)
	SingleMap.validate_sizes_of_arrays(single_map)

	var choosen_player: int

	for y in range(single_map.size.y):
		for x in range(single_map.size.x):
			if single_map.fields[y][x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
				choosen_player = randi() % (number_of_players + 1) - 1

				if choosen_player != -1:
					single_map.fields[y][x] = SingleMap.FIELD_TYPE.PLAYER_FIRST + choosen_player

				if randi() % 100 < ant_chance:
					single_map.add_unit(Vector2j.new(x, y), randi() % (Units.TYPES_OF_ANTS.ANT_MAX), 1)

				if randi() % 2 == 0 && single_map.building_get_place_for_build(Vector2j.new(x, y)) != -1:
					single_map.building_add(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.ANTHILL, randi() % 3 + 1)
				if randi() % 2 == 0 && single_map.building_get_place_for_build(Vector2j.new(x, y)) != -1:
					single_map.building_add(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.FARM, randi() % 3 + 1)
				if randi() % 2 == 0 && single_map.building_get_place_for_build(Vector2j.new(x, y)) != -1:
					single_map.building_add(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.SAWMILL, randi() % 3 + 1)
				if randi() % 2 == 0 && single_map.building_get_place_for_build(Vector2j.new(x, y)) != -1:
					single_map.building_add(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.BARRACKS, randi() % 3 + 1)
				if randi() % 2 == 0 && single_map.building_get_place_for_build(Vector2j.new(x, y)) != -1:
					single_map.building_add(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.PILE, randi() % 3 + 1)
				if randi() % 2 == 0 && single_map.building_get_place_for_build(Vector2j.new(x, y)) != -1:
					single_map.building_add(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.GOLD_MINE, randi() % 3 + 1)


## Tworzy tablicę odległości danych pól od graczy
func pm_fully_create_distance_array(fields: Array, players: Array) -> Array:
	var smallest_array: Array = []  # Tablica z najmniejszymi odległościami od wybranych
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
							if !Vector2j.is_in_array(checked, Vector2j.new(cep_x, cep_y)) && !Vector2j.is_in_array(to_check, Vector2j.new(cep_x, cep_y)):
								if fields[cep_y][cep_x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
									if smallest_array[cep_y][cep_x] == -1 || smallest_array[cep_y][cep_x] > current_value:
										smallest_array[cep_y][cep_x] = current_value + 1
										to_check.append(Vector2j.new(cep_x, cep_y))
										to_check_value.append(current_value + 1)

			assert(!Vector2j.is_in_array(checked, current_element))

			checked.append(current_element)
		checked = []
		to_check = []
		to_check_value = []

	return smallest_array


## Wybiera jeden z najdalszych punktów z tablicy odległości, tak aby poszczególni gracze znajdowali się daleko od siebie, ale nie zawsze na granicy mapy
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
		# TODO - To może się zdarzyć gdy liczba graczy jest równa liczbie terenów, dlatego należy przecidziałać temu już na etapie blokady możliwości nadania zbyt małej ilości terenów
		assert(false)
		return Vector2j.new(0, 0)

	return biggest_numbers[randi() % biggest_numbers.size()]


func populate_map_buildings(single_map: SingleMap) -> void:
	# Add Anthill of first level
	for coordinates in single_map.players:
		single_map.building_add(coordinates, Buildings.TYPES_OF_BUILDINGS.ANTHILL, 1)

	# Randomly put with 30 % chance one building
	for x in single_map.size.x:
		for y in single_map.size.y:
			if randi() % 10 < 3:
				single_map.building_add(Vector2j.new(x, y), randi() % (Buildings.NUMBER_OF_BUILDINGS - 1) + 1, 1)


## Tworzy mapę 3D, którą można użyć w Scene Tree(Jest to zwykły Node)
func create_3d_map(single_map: SingleMap) -> void:
	var map: Spatial = Spatial.new()
	map.set_name("Map")

	single_map.set_map(map)

	# Przed wygenerowaniem mapy ładnie ją centruje, ponieważ chcę aby mapa miała współrzędne (0,0)
	var move_translation: Vector3 = center_map(single_map)

	for y in single_map.size.y:
		for x in single_map.size.x:
			## Fields
			if single_map.fields[y][x] != SingleMap.FIELD_TYPE.NO_FIELD:
				var SH: MeshInstance = SingleHex.instance()
				SH.translation = Vector3(x * SINGLE_HEX_DIMENSION.x, randf(), y * SINGLE_HEX_DIMENSION.y * 0.75)
				# Przesunięcie względem mapy
				SH.translation += move_translation

				if y % 2 == 1:
					SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x, 0, 0)
				SH.set_name(NODE_BASE_NAME + str(y * single_map.size.x + x))

				if single_map.fields[y][x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
					SH.set_surface_material(0, texture_base)
				else:
					SH.set_surface_material(0, texture_array[single_map.fields[y][x] - SingleMap.FIELD_TYPE.PLAYER_FIRST])
				map.add_child(SH)
				SH.set_owner(map)

				## Units
				if !single_map.units[y][x].empty():
					var ant: Spatial = AntsArray[single_map.units[y][x]["type"]].instance()

					ant.translation = Vector3(0, 1.192, 0)

					if single_map.fields[y][x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
						ant.find_node("Outfit").set_surface_material(0, ant_base)
					else:
						ant.find_node("Outfit").set_surface_material(0, ant_texture_array[single_map.fields[y][x] - SingleMap.FIELD_TYPE.PLAYER_FIRST])
					SH.add_child(ant)
					ant.set_owner(map)
					pass
				## Buildings
				if single_map.buildings[y][x].has(Buildings.TYPES_OF_BUILDINGS.ANTHILL):
					var anthill = Anthill.instance()
					anthill.translation = single_map.building_get_place_where_is_building(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.ANTHILL)

					SH.add_child(anthill)
					anthill.set_owner(map)

				if single_map.buildings[y][x].has(Buildings.TYPES_OF_BUILDINGS.FARM):
					var farm = Farm.instance()
					farm.translation = single_map.building_get_place_where_is_building(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.FARM)

					SH.add_child(farm)
					farm.set_owner(map)

				if single_map.buildings[y][x].has(Buildings.TYPES_OF_BUILDINGS.SAWMILL):
					var sawmill = Sawmill.instance()
					sawmill.translation = single_map.building_get_place_where_is_building(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.SAWMILL)

					SH.add_child(sawmill)
					sawmill.set_owner(map)

				if single_map.buildings[y][x].has(Buildings.TYPES_OF_BUILDINGS.BARRACKS):
					var barracks = Barracks.instance()
					barracks.translation = single_map.building_get_place_where_is_building(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.BARRACKS)

					SH.add_child(barracks)
					barracks.set_owner(map)

				if single_map.buildings[y][x].has(Buildings.TYPES_OF_BUILDINGS.GOLD_MINE):
					var gold_mine = GoldMine.instance()
					gold_mine.translation = single_map.building_get_place_where_is_building(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.GOLD_MINE)

					SH.add_child(gold_mine)
					gold_mine.set_owner(map)

				if single_map.buildings[y][x].has(Buildings.TYPES_OF_BUILDINGS.PILE):
					var piles = Piles.instance()
					piles.translation = single_map.building_get_place_where_is_building(Vector2j.new(x, y), Buildings.TYPES_OF_BUILDINGS.PILE)

					SH.add_child(piles)
					piles.set_owner(map)


## Dokładnie centruje mapę
func center_map(single_map: SingleMap) -> Vector3:
	assert(single_map.size.x > 0 && single_map.size.y > 0)
	var translation: Vector3 = Vector3()

	single_map.real_map_size.x = single_map.size.x * SINGLE_HEX_DIMENSION.x
	## Gdy w parzystej linii na końcu jest obecny hex, to wtedy wymiary mapy są większe niż zazwyczaj
	for y in range(1, single_map.size.y, 2):
		if single_map.fields[y][single_map.size.x - 1] != SingleMap.FIELD_TYPE.NO_FIELD:
			single_map.real_map_size.x += SINGLE_HEX_DIMENSION.x / 2.0
			break

	single_map.real_map_size.y = SINGLE_HEX_DIMENSION.y * 0.25 + single_map.size.y * (SINGLE_HEX_DIMENSION.y * 0.75)

	# Mapa początkowo jest już przesunięta tak aby wskazywała na środek pierwszego hexa, dlatego należy to skoregować
	translation.x -= (single_map.real_map_size.x - SINGLE_HEX_DIMENSION.x) / 2.0
	translation.z -= (single_map.real_map_size.y - SINGLE_HEX_DIMENSION.y) / 2.0

	# Zwraca przesunięcie, które trzeba wykonać na każdym z elementów
	return translation
