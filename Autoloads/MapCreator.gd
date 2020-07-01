extends Node

var SingleHex : PackedScene = load("res://Terrain/SingleHex/SingleHex.tscn")
var Ant : PackedScene = load("res://Units/Ant.tscn")

const SINGLE_HEX_DIMENSION : Vector2 = Vector2(1.732,1.5)
const NODE_BASE_NAME : String = "SingleHex"
var texture_base : SpatialMaterial 
var texture_array : Array = []
var ant_base : SpatialMaterial
var ant_array : Array = []

func _ready() -> void:
	
	randomize() # Bez tego za każdym razem wychdzą takie same wyniki randi()

	assert(GameSettings.MAX_TEAMS == 4) # Należy dodać więcej wyglądu
	
	texture_base = load("res://Terrain/SingleHex/SingleHexBase.tres")
	ant_base = load("res://Units/Outfit/OutfitBase.tres")
	
	for i in range(0,GameSettings.MAX_TEAMS):
		texture_array.append(load("res://Terrain/SingleHex/SingleHexTEAM" + str(i + 1) + ".tres"))
		ant_array.append(load("res://Units/Outfit/OutfitTEAM" + str(i + 1) + ".tres"))
	
	
func generate_full_map(var hex_number : Vector2) -> void:#, var number_of_players : int = GameSettings.MAX_TEAMS) -> void:
	
	assert(hex_number.x > 0 && hex_number.y > 0)
	
	var START_POSITION : Vector3 = Vector3(SINGLE_HEX_DIMENSION.x / 2.0, 0.0 , SINGLE_HEX_DIMENSION.y / 2.0) # Początkowe przesuniecie, nie idealne, ale może być
	
	var map : Spatial = Spatial.new()
	map.set_name("Map")
	map.set_translation(Vector3(-hex_number.y * SINGLE_HEX_DIMENSION.x / 2.0,0,-hex_number.x * SINGLE_HEX_DIMENSION.y / 2.0)) # Wyrównuje 
	
	for i in hex_number.x:
		for j in hex_number.y:
			var SH : MeshInstance = SingleHex.instance()
			SH.translation = START_POSITION + Vector3(j*SINGLE_HEX_DIMENSION.x,randf(),i*SINGLE_HEX_DIMENSION.y)
			if i%2 == 1:
				SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x,0,0)
			SH.set_name(NODE_BASE_NAME + str(i * hex_number.y + j))
			var mat : SpatialMaterial = texture_base
				
			SH.set_surface_material(0,mat)
			map.add_child(SH)
			SH.set_owner(map)

	
	var packed_scene = PackedScene.new()
	packed_scene.pack(map)
#	if(ResourceSaver.save("user://GeneratedMap.tscn", packed_scene) != OK):
	if(ResourceSaver.save("res://GeneratedMap.tscn", packed_scene,ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS) != OK):
		printerr("Nie powiodła się próba zapisu mapy")
	map.queue_free()

func generate_partial_map(var hex_number : Vector2, var chance_to_terrain : int) -> void:#, var number_of_players : int = GameSettings.MAX_TEAMS) -> void:
	
	assert(hex_number.x > 0 && hex_number.y > 0)
	assert(chance_to_terrain >= 50 && chance_to_terrain < 101) # Aby zapobiec zbyt zbyt wielkiej rekurencji
	
	var START_POSITION : Vector3 = Vector3(SINGLE_HEX_DIMENSION.x / 2.0, 0.0 , SINGLE_HEX_DIMENSION.y / 2.0) # Początkowe przesuniecie, nie idealne, ale może być
	
	var map : Spatial = Spatial.new()
	map.set_name("Map")
	map.set_translation(Vector3(-hex_number.y * SINGLE_HEX_DIMENSION.x / 2.0,0,-hex_number.x * SINGLE_HEX_DIMENSION.y / 2.0)) # Wyrównuje 

	
	var array : Array = []
	for i in hex_number.x:
		array.append([])
		for j in hex_number.y:
			array[array.size() - 1].append(0)
				
				
	# Wybierz jeden ląd na górze
	var first_element : int = randi() % array.size()
	array[0][first_element] = 1
				
	var to_check : Array = []
	var checked : Array = []
	var current_element : Vector2i = Vector2i.new(0,0)
	
	var ce_x : int = 0
	var ce_y : int = 0
	while true:
		to_check.append(Vector2i.new(0,first_element))
		print(array[0][first_element])
		while to_check.size() > 0:
			current_element = to_check.pop_front()
			
#			if array[current_element.x][current_element.y] == 0:
#				continue
			
			assert(array[current_element.x][current_element.y] == 1)
			assert(current_element.x < array.size() && current_element.x >= 0)
			assert(current_element.y < array.size() && current_element.y >= 0)
			
			var help_array_1 = [[-1,-1],
								[-1, 0],
								[-1, 1],
								[ 0,-1],
								[ 0, 1],
								[ 1, 0]]
								
			for i in range(6):
				if (current_element.x + help_array_1[i].x > 0) && (current_element.x + help_array_1[i].x < array.size() - 1) && (current_element.y + help_array_1[i].y > 0) && (current_element.y + help_array_1[i].y < array.size() - 1) :
					var cep_x = current_element.x + help_array_1[i].x
					var cep_y = current_element.y + help_array_1[i].y
					if !Vector2i.is_in_array(checked,Vector2i.new(cep_x,cep_y)):
					pass
			
			if current_element.y % 2 == 1:
	#					array[i - 1][j - 1] == 1
	#					array[i - 1][  j  ] == 1
	#					array[i - 1][j + 1] == 1
	#					array[  i  ][j - 1] == 1
	#					array[  i  ][j + 1] == 1
	#					array[i + 1][  j  ] == 1
				if (current_element.x > 0 && current_element.y > 0):
					ce_x = current_element.x - 1
					ce_y = current_element.y - 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						assert(array[ce_x][ce_y] == 0)
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.x > 0):
					ce_x = current_element.x - 1
					ce_y = current_element.y
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.x > 0 && current_element.y < array.size() - 1):
					ce_x = current_element.x - 1
					ce_y = current_element.y + 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.y > 0):
					ce_x = current_element.x
					ce_y = current_element.y - 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.y < array.size() - 1):
					ce_x = current_element.x
					ce_y = current_element.y + 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.x < array.size() - 1):
					ce_x = current_element.x + 1
					ce_y = current_element.y
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
			else:
	#					array[i + 1][j - 1] == 1
	#					array[i + 1][  j  ] == 1
	#					array[i + 1][j + 1] == 1
	#					array[  i  ][j - 1] == 1
	#					array[  i  ][j + 1] == 1
	#					array[i - 1][  j  ] == 1
				if (current_element.x < array.size() - 1 && current_element.y > 0):
					ce_x = current_element.x + 1
					ce_y = current_element.y - 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.x < array.size() - 1):
					ce_x = current_element.x + 1
					ce_y = current_element.y
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.x < array.size() - 1 && current_element.y < array.size() - 1):
					ce_x = current_element.x + 1
					ce_y = current_element.y + 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.y > 0):
					ce_x = current_element.x
					ce_y = current_element.y - 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.y < array.size() - 1):
					ce_x = current_element.x
					ce_y = current_element.y + 1
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				if (current_element.x > 0):
					ce_x = current_element.x - 1
					ce_y = current_element.y
					if !Vector2i.is_in_array(checked,Vector2i.new(ce_x,ce_y)):
						array[ce_x][ce_y] = int(randi() % 100 < chance_to_terrain)
						if array[ce_x][ce_y] == 1:
							to_check.append(Vector2i.new(ce_x,ce_y))
						else:
							checked.append(Vector2i.new(ce_x,ce_y))
				
			for i in to_check:
				if array[i.x][i.y] == 0:
					print("HUUH")

			if Vector2i.is_in_array(checked,current_element):
				print("Co do chuja")
			checked.append(current_element)
			
		# Jest niewielka szansa, że nie zostanie stworzony żaden hex, dlatego szansę tą zmniejszamy wielokrotnie
		if checked.size() > 5:
			break
		elif hex_number.x * hex_number.y < 4:
			break
			
		to_check.clear()
		checked.clear()
		for i in array:
			for j in i:
				j = 0
		array[0][first_element] = 1
			

	for i in hex_number.x:
		for j in hex_number.y:
			if array[i][j] == 1:
				var SH : MeshInstance = SingleHex.instance()
				SH.translation = START_POSITION + Vector3(j*SINGLE_HEX_DIMENSION.x,randf(),i*SINGLE_HEX_DIMENSION.y)
				if i%2 == 1:
					SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x,0,0)
				SH.set_name(NODE_BASE_NAME + str(i * hex_number.y + j))
				var mat : SpatialMaterial = texture_base
					
				SH.set_surface_material(0,mat)
				map.add_child(SH)
				SH.set_owner(map)

	
	var packed_scene = PackedScene.new()
	packed_scene.pack(map)
#	if(ResourceSaver.save("user://GeneratedMap.tscn", packed_scene) != OK):
	if(ResourceSaver.save("res://GeneratedMap.tscn", packed_scene,ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS) != OK):
		printerr("Nie powiodła się próba zapisu mapy")
	map.queue_free()

	
func populate_random_map(var ant_chance : int = 100, var number_of_players : int = GameSettings.MAX_TEAMS) -> void:
	assert(number_of_players > 0 && number_of_players <= GameSettings.MAX_TEAMS)
	assert(ant_chance >= 0 && ant_chance < 101)
	
	var map : Spatial = load("res://GeneratedMap.tscn").instance()
	var mat : SpatialMaterial
	
	var choosen_material : int
	
	
	for i in map.get_children():
		choosen_material = randi() % (number_of_players + 1)
		if choosen_material == 0: # Materiał dla hexa
			mat = texture_base
		else:
			mat = texture_array[choosen_material - 1]
		i.set_surface_material(0,mat)
		
		if choosen_material == 0: # Materiał dla mrówki
			mat = ant_base
		else:
			mat = ant_array[choosen_material - 1]
		
		if randi() % 100 < ant_chance:
			var AN : Spatial = Ant.instance()
			
			var new_ant : Spatial = Spatial.new()
			new_ant.set_name("Ant")
			new_ant.set_transform(AN.get_transform())
			new_ant.set_translation(Vector3(0.0,1.2,0.0))
			
			var outfit : MeshInstance = MeshInstance.new()
			outfit.set_name("Outfit")
			outfit.set_mesh(AN.get_node("Outfit").get_mesh())
			outfit.set_transform(AN.get_node("Outfit").get_transform())
			var helmet : MeshInstance = MeshInstance.new()
			helmet.set_name("Helmet")
			helmet.set_mesh(AN.get_node("Helmet").get_mesh())
			helmet.set_transform(AN.get_node("Helmet").get_transform())
			var body : MeshInstance = MeshInstance.new()
			body.set_name("Body")
			body.set_mesh(AN.get_node("Body").get_mesh())
			body.set_transform(AN.get_node("Body").get_transform())
			body.set_surface_material(0,load("res://Units/Body/Body.tres"))
			
			new_ant.add_child(outfit)
			new_ant.add_child(helmet)
			new_ant.add_child(body)
			
			outfit.set_surface_material(0,mat)
			i.add_child(new_ant)
			new_ant.set_owner(map)
			outfit.set_owner(map)
			helmet.set_owner(map)
			body.set_owner(map)
			
			AN.queue_free()	
	
			
	var packed_scene = PackedScene.new()
	packed_scene.pack(map)
#	if(ResourceSaver.save("user://GeneratedMap.tscn", packed_scene) != OK):
	
	if(ResourceSaver.save("res://GeneratedMap.tscn", packed_scene) != OK):
		printerr("Nie powiodła się próba zapisu mapy")
	
	map.queue_free()
	
