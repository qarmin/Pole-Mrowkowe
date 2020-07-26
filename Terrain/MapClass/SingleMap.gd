class_name SingleMap

var map: Spatial
var size: Vector2  # GD40 Vector2i
var fields: Array  # Dwuwymiarowa tablica z zaznaczonymi polami, gdzie które się znajduje, tak aby nie trzeba było cały czas sięgać po tablicę
var number_of_terrain: int
var number_of_all_possible_hexes: int
var players: Array
var starts_with_offset : bool = false #W przypadku jeśli dana mapa rozpoczyna się od przesuniętego linii parzystej(nie 1, może się to zdarzyć gdy mapa jest ucinana), to należy skorygować ułożenie mapy


func reset() -> void:
	if map != null:
		map.queue_free()
		map = null

	size = Vector2()
	fields.clear()
	number_of_terrain = 0
	number_of_all_possible_hexes = 0
	players.clear()
	
	starts_with_offset = false

## Settery

func set_size(new_size: Vector2) -> void:
	size = new_size
	number_of_all_possible_hexes = int(size.x) * int(size.y)  # GH40
	number_of_terrain = 0


func set_players(new_players: Array) -> void:
	players = new_players


func set_map(new_map: Spatial) -> void:
	assert(map == null)  # Nie wyczyszczono starej mapy poprawnie
	map = new_map
	calculate_real_size() # Usuwa niepotrzebne tereny 


func set_fields(new_fields: Array) -> void:
	fields = new_fields
	assert(fields.size() == int(size.y))
	
	for i in range(size.y):
		for j in range(size.x):
			if fields[i][j] != MapCreator.FIELD_TYPE.NO_FIELD:
				number_of_terrain += 1
	
	


func set_number_of_terrain(new_number_of_terrain: int) -> void:
	number_of_terrain = new_number_of_terrain

## Inne funkcje

func calculate_real_size() -> void:
	var real_min_x : int = -1
	var real_max_x : int = -1
	var real_min_y : int = -1
	var real_max_y : int = -1

	print_map(fields)
	for y in size.y:
		for x in size.x:
			if fields[y][x] != MapCreator.FIELD_TYPE.NO_FIELD:
				if real_min_x == -1:
					real_min_x = x
					real_max_x = x
				else:
					if real_min_x > x:
						real_min_x = x
					if real_max_x < x:
						real_max_x = x
				if real_min_y == -1:
					real_min_y = y
					real_max_y = y
				else:
					if real_min_y > y:
						real_min_y = y
					if real_max_y < y:
						real_max_y = y
						
	
	if (real_max_x - real_min_x + 1) != fields[0].size() || (real_max_y - real_min_y + 1) != fields.size():
		print("TODO: Trzeba zmniejszyć mapę")
		var new_fields : Array = []
		for y in range(real_min_y,(real_max_y+1)):
			new_fields.append([])
			for x in range(real_min_x,(real_max_x+1)):
				new_fields[y - real_min_y].append(fields[y][x])
		
		var base_offset : int = (real_min_y * int(size.x)) + real_min_x # Ile numerów należy usunąć przed 
		var second_offset : int = (real_min_x) + (int(size.x) - real_max_x - 1)
		# Zmiana nazw hexów
		for i in map.get_children():
			var number : int = i.get_name().trim_prefix(MapCreator.NODE_BASE_NAME).to_int()
			
			print(i.get_name() + " :: " + str(number))
		
		if real_min_y % 2 == 1:
			starts_with_offset = true
		else:
			starts_with_offset = false
	else:
		print("INFO: Nie trzeba zmniejszać mapy")
	print_map(fields)


func initialize_fields() -> void:
	for i in range(size.y):
		fields.append([])
		for _j in range(size.x):
			fields[i].append(MapCreator.FIELD_TYPE.NO_FIELD)


func initialize_full_fields() -> void:
	for i in range(size.y):
		fields.append([])
		for _j in range(size.x):
			fields[i].append(MapCreator.FIELD_TYPE.DEFAULT_FIELD)
	number_of_terrain = number_of_all_possible_hexes


static func print_map(array: Array) -> void:
	print("Printed map")
	for i in range(array.size()):
		var line: String = ""
		if i % 2 == 1:
			line += "  "
		for j in range(array[i].size()):
			line += str(array[i][j]) + "  "
			if array[i][j] < 10 && array[i][j] >= 0:
				line += " "
		print(line)
