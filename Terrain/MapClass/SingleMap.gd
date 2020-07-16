class_name SingleMap

var map : Spatial
var size : Vector2 # GD40 Vector2i
var fields : Array # Dwuwymiarowa tablica z zaznaczonymi polami, gdzie które się znajduje, tak aby nie trzeba było cały czas sięgać po tablicę
var number_of_terrain : int
var number_of_all_possible_hexes : int
var players : Array


func reset() -> void:
	if map != null:
		map.queue_free()
		map = null
	
	size = Vector2()
	fields.clear()
	number_of_terrain = 0
	number_of_all_possible_hexes = 0
	players.clear()
	
	
func set_size(var new_size : Vector2) -> void:
	size = new_size
	number_of_all_possible_hexes = int(size.x) * int(size.y) # GH40
	number_of_terrain = 0
	
func set_players(var new_players : Array) -> void:
	players = new_players
	
func set_map(var new_map : Spatial) -> void:
	assert(map == null) # Nie wyczyszczono starej mapy poprawnie
	map = new_map

func set_fields(var new_fields : Array) -> void:
	fields = new_fields
	assert(fields.size() == int(size.y))
	
	for i in range(size.y):
		for j in range(size.x):
			if fields[i][j] == 1:
				number_of_terrain += 1

func set_number_of_terrain(var new_number_of_terrain : int) -> void:
	number_of_terrain = new_number_of_terrain

func initialize_fields() -> void:
	for i in range(size.y):
		fields.append([])
		for _j in range(size.x):
			fields[i].append(0)
			
func initialize_full_fields() -> void:
	for i in range(size.y):
		fields.append([])
		for _j in range(size.x):
			fields[i].append(1)
	number_of_terrain = number_of_all_possible_hexes
			
static func print_map(array: Array) -> void:
	print("Printed map")
	for i in range(array.size()):
		var line: String = ""
		if i % 2 == 1:
			line += "  "
		for j in range(array[i].size()):
			line += str(array[i][j]) + "  "
			if array[i][j] < 10:
				line += " "
		print(line)
