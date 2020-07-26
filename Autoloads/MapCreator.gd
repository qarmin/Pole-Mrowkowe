extends Node

var SingleHex: PackedScene = load("res://Terrain/SingleHex/SingleHex.tscn")
var Ant: PackedScene = load("res://Units/Ant.tscn")

enum FIELD_TYPE { NO_FIELD = -100, DEFAULT_FIELD = -1, PLAYER_1 = 0 }

#const NO_FIELD : int = -100
#const DEFAULT_FIELD : int = -1
#const FIRST_PLAYER : int = 0

const SINGLE_HEX_DIMENSION: Vector2 = Vector2(1.732, 1.5)
const NODE_BASE_NAME: String = "SingleHex"
var texture_base: SpatialMaterial
var texture_array: Array = []
var ant_base: SpatialMaterial
var ant_texture_array: Array = []


func _ready() -> void:
	randomize()  # Bez tego za każdym razem wychdzą takie same wyniki randi()

	assert(GameSettings.MAX_TEAMS == 4)  # Należy dodać więcej wyglądów

	texture_base = load("res://Terrain/SingleHex/SingleHexBase.tres")
	ant_base = load("res://Units/Outfit/OutfitBase.tres")

	for i in range(0, GameSettings.MAX_TEAMS):
		texture_array.append(load("res://Terrain/SingleHex/SingleHexTEAM" + str(i + 1) + ".tres"))
		ant_texture_array.append(load("res://Units/Outfit/OutfitTEAM" + str(i + 1) + ".tres"))


func generate_full_map(single_map: SingleMap, hex_number: Vector2) -> void:
	single_map.set_size(hex_number)
	single_map.initialize_full_fields()

	assert(hex_number.x > 0 && hex_number.y > 0)

	var START_POSITION: Vector3 = Vector3(SINGLE_HEX_DIMENSION.x / 2.0, 0.0, SINGLE_HEX_DIMENSION.y / 2.0)  # Początkowe przesuniecie, nie idealne, ale może być

	var map: Spatial = Spatial.new()
	map.set_name("Map")
	map.set_translation(Vector3(-hex_number.y * SINGLE_HEX_DIMENSION.x / 2.0, 0, -hex_number.x * SINGLE_HEX_DIMENSION.y / 2.0))  # Wyrównuje 

	for i in hex_number.x:
		for j in hex_number.y:
			var SH: MeshInstance = SingleHex.instance()
			SH.translation = START_POSITION + Vector3(j * SINGLE_HEX_DIMENSION.x, randf(), i * SINGLE_HEX_DIMENSION.y)
			if i % 2 == 1:
				SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x, 0, 0)
			SH.set_name(NODE_BASE_NAME + str(i * hex_number.y + j))
			var mat: SpatialMaterial = texture_base

			SH.set_surface_material(0, mat)
			map.add_child(SH)
			SH.set_owner(map)

	single_map.set_map(map)


func generate_partial_map(single_map: SingleMap, hex_number: Vector2, chance_to_terrain: int) -> void:
	single_map.set_size(hex_number)
	single_map.initialize_fields()

	assert(hex_number.x > 0 && hex_number.y > 0)
	assert(chance_to_terrain > 0 && chance_to_terrain < 101)

	var START_POSITION: Vector3 = Vector3(SINGLE_HEX_DIMENSION.x / 2.0, 0.0, SINGLE_HEX_DIMENSION.y / 2.0)  # Początkowe przesuniecie, nie idealne, ale może być

	var map: Spatial = Spatial.new()
	map.set_name("Map")
	map.set_translation(Vector3(-hex_number.x * SINGLE_HEX_DIMENSION.x / 2.0, 0, -hex_number.y * SINGLE_HEX_DIMENSION.y / 2.0))  # Wyrównuje 

	var array: Array = []
	for i in hex_number.y:
		array.append([])
		for j in hex_number.x:
			array[array.size() - 1].append(FIELD_TYPE.NO_FIELD)

	var to_check: Array = []
	var checked: Array = []
	var current_element: Vector2j = Vector2j.new(0, 0)  # GH40 - zmienić na Vector2i

	while true:
		# Resetowanie tablicy
		for i in range(hex_number.x):
			for j in range(hex_number.y):
				array[j][i] = FIELD_TYPE.NO_FIELD

		# Wybrany jeden ląd ze środka
		array[int(hex_number.y / 2)][int(hex_number.x / 2)] = FIELD_TYPE.DEFAULT_FIELD
		to_check.append(Vector2j.new(int(hex_number.x / 2), int(hex_number.y / 2)))
		assert(array[int(hex_number.y / 2)][int(hex_number.x / 2)] == FIELD_TYPE.DEFAULT_FIELD)

		#print("Start Point = " + str(int(hex_number.x / 2)) + "x, " + str(int(hex_number.y / 2)) + "y")
		#print("Start Array")
		#SingleMap.print_map(array)
		while to_check.size() > 0:
			current_element = to_check.pop_front()

			#print("Sprawdzam teraz punkt " + str(current_element.x) + " " + str(current_element.y))
			assert(array[current_element.y][current_element.x] == FIELD_TYPE.DEFAULT_FIELD)
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
								assert(array[cep_y][cep_x] == FIELD_TYPE.NO_FIELD)
								var is_terrain : bool = randi() % 100 < chance_to_terrain
								if is_terrain:
									array[cep_y][cep_x] = FIELD_TYPE.DEFAULT_FIELD
									to_check.append(Vector2j.new(cep_x, cep_y))
								else:
									array[cep_y][cep_x] = FIELD_TYPE.NO_FIELD
									checked.append(Vector2j.new(cep_x, cep_y))

			#SingleMap.print_map(array)
			for i in to_check:
				assert(array[i.y][i.x] == FIELD_TYPE.DEFAULT_FIELD)

			assert(! Vector2j.is_in_array(checked, current_element))

			checked.append(current_element)

		# Jeśli wygenerowano stanowczo za mało hexów, to powtarzamy ich tworzenie
		var number_of_real_hex: int = 0
		for i in array:
			for j in i:
				if j == FIELD_TYPE.DEFAULT_FIELD:
					number_of_real_hex += 1

#		# Wystarczy tylko 66% wymaganych pól
#		if hex_number.x * hex_number.y * chance_to_terrain / 1.5 < 100 * number_of_real_hex:
#			break
		if hex_number.x * hex_number.y * (chance_to_terrain * chance_to_terrain * 0.75) < 100 * 100 * number_of_real_hex:
			break

		to_check.clear()
		checked.clear()

		print("Nie udało mi się stworzyć poprawnego algrotymu, sprawdzam ponownie")
#		SingleMap.print_map(array)

	single_map.set_fields(array)

	for i in hex_number.x:
		for j in hex_number.y:
			if array[j][i] == FIELD_TYPE.DEFAULT_FIELD:
				var SH: MeshInstance = SingleHex.instance()
				SH.translation = START_POSITION + Vector3(i * SINGLE_HEX_DIMENSION.x, randf(), j * SINGLE_HEX_DIMENSION.y)
				if j % 2 == 1:
					SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x, 0, 0)
				SH.set_name(NODE_BASE_NAME + str(j * hex_number.x + i))
				var mat: SpatialMaterial = texture_base

				SH.set_surface_material(0, mat)
				map.add_child(SH)
				SH.set_owner(map)

	single_map.set_map(map)


func populate_map(single_map: SingleMap, number_of_players: int = GameSettings.MAX_TEAMS, max_number_of_additional_terrains: int = 0) -> void:
	assert(number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS)
	assert(single_map.number_of_terrain > 2 * number_of_players)
	assert(max_number_of_additional_terrains >= 0)

	var temp_fields: Array
	var curr: Vector2j = Vector2j.new(0, 0)

	# Wybieranie miejsca dla pierwszego gracza
	while true:
		curr.x = randi() % int(single_map.size.x)
		curr.y = randi() % int(single_map.size.y)
		if single_map.fields[curr.y][curr.x] == FIELD_TYPE.DEFAULT_FIELD:
			single_map.players.append(curr)
			break

	# Wybieranie miejsc dla innych graczy
	while single_map.players.size() < number_of_players:
		temp_fields = recalculate_map(single_map.fields, single_map.players)
		single_map.players.append(choose_one_of_closer_point(temp_fields, single_map.number_of_terrain, number_of_players))

	# Narysowanie głównego miejsca dla każdego z osób/przeciwników

	var single_hex: Spatial

	for i in range(single_map.players.size()):
		single_hex = single_map.map.get_node(NODE_BASE_NAME + str(single_map.players[i].y * single_map.size.x + single_map.players[i].x))
		single_hex.set_surface_material(0, texture_array[i])

	# Ustawienie tyle ile się da pól obok, ile tylko się da
#	var terrain_to_check : Array = []
#	var terrain_checked : Array = []
	push_warning("TODO - Dodać określoną liczbę początkową pól(nie wiem jak do końca to zaimplementować), póki co jest jedno pole dla każdego gracza.")
#	while(max_number_of_additional_terrains > 0):
#		for i in range(single_map.players.size()):
#
#
#
#			pass
#		max_number_of_additional_terrains -= 1

	push_warning("TODO - Dodać podstawowe budynki do mapy podczas tworzeni - np. główne mrowisko")

#	## START PRINT MAP
#	SingleMap.print_map(single_map.fields)
#
#	for i in single_map.players:
#		single_map.fields[i.y][i.x] = 88

#	SingleMap.print_map(single_map.fields)
#	## END PRINT MAP
	return


func recalculate_map(fields: Array, players: Array) -> Array:
	var smallest_array: Array = [] # Tablica z najmniejszymi odległościami od 
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


func choose_one_of_closer_point(array: Array, number_of_terrain: int, number_of_players: int) -> Vector2j:
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
		assert(false)
		return Vector2j.new(0, 0)

	return biggest_numbers[randi() % biggest_numbers.size()]


func serialize_map(_single_map: SingleMap) -> void:
	push_warning("TODO - Serializacja mapy")


func deserialize_map() -> void:
	push_warning("TODO - Wczytywanie mapy z pliku i jej tworzenie")


func populate_map_buildings(_single_map: SingleMap) -> void:
	push_warning("TODO - Tworzenie głównej siedziby i być może jakichś podstawowych budynków, może być przydatne przy tworzeniu mapy")


func populate_random_map(single_map: SingleMap, ant_chance: int = 100, number_of_players: int = GameSettings.MAX_TEAMS) -> void:
	assert(number_of_players > 1 && number_of_players <= GameSettings.MAX_TEAMS)
	assert(ant_chance >= 0 && ant_chance < 101)

	var mat: SpatialMaterial

	var choosen_material: int

	for i in single_map.map.get_children():
		choosen_material = randi() % (number_of_players + 1)
		if choosen_material == 0:  # Materiał dla hexa
			mat = texture_base
		else:
			mat = texture_array[choosen_material - 1]
		i.set_surface_material(0, mat)

		if choosen_material == 0:  # Materiał dla mrówki
			mat = ant_base
		else:
			mat = ant_texture_array[choosen_material - 1]

		if randi() % 100 < ant_chance:
			var AN: Spatial = Ant.instance()

			var new_ant: Spatial = Spatial.new()
			new_ant.set_name("Ant")
			new_ant.set_transform(AN.get_transform())
			new_ant.set_translation(Vector3(0.0, 1.2, 0.0))

			var outfit: MeshInstance = MeshInstance.new()
			outfit.set_name("Outfit")
			outfit.set_mesh(AN.get_node("Outfit").get_mesh())
			outfit.set_transform(AN.get_node("Outfit").get_transform())
			var helmet: MeshInstance = MeshInstance.new()
			helmet.set_name("Helmet")
			helmet.set_mesh(AN.get_node("Helmet").get_mesh())
			helmet.set_transform(AN.get_node("Helmet").get_transform())
			var body: MeshInstance = MeshInstance.new()
			body.set_name("Body")
			body.set_mesh(AN.get_node("Body").get_mesh())
			body.set_transform(AN.get_node("Body").get_transform())
			body.set_surface_material(0, load("res://Units/Body/Body.tres"))

			new_ant.add_child(outfit)
			new_ant.add_child(helmet)
			new_ant.add_child(body)

			outfit.set_surface_material(0, mat)
			i.add_child(new_ant)
			new_ant.set_owner(single_map.map)
			outfit.set_owner(single_map.map)
			helmet.set_owner(single_map.map)
			body.set_owner(single_map.map)

			AN.queue_free()


func save_map(single_map: SingleMap, destroy: bool = false) -> void:
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

#	return map
