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
				
	var generated_array : Array = array
	while true: # Dopóki nie wygeneruje się mapa jaką można dojść z jednego do drugiego miejsca
		var can_exit : bool = false
		while true: # Musi zostać wygenerowana na początku przynajmniej jeden ląd na samej górze
			for i in hex_number.y:
				if array[0][i] == 1:
					can_exit = true
					break
			if can_exit:
				break
			for i in hex_number.y:
				if randi() % 100 < chance_to_terrain:
					array[0][i] = 1
					
		
		# Teraz generowane są połączenia
		var have_neighbour : bool
		var LOOK_AT_LEFT : bool = false
		for i in range(1,hex_number.x):
			for j in hex_number.y:
				if j % 2 == 0:
					if i > 0:
						if j > 0:
							if array[i - 1][j - 1] == 1:
								have_neighbour = true
						if j < hex_number.y - 1:
							if array[i - 1][j + 1] == 1:
								have_neighbour = true
						if array[i - 1][  j  ] == 1:
							have_neighbour = true
					
					if LOOK_AT_LEFT:
						if j > 0:
							if array[  i  ][j - 1] == 1:
								have_neighbour = true
				else:
					if i > 0:
						if j > 0:
							if array[i - 1][j - 1] == 1:
								have_neighbour = true
						if j < hex_number.y - 1:
							if array[i - 1][j + 1] == 1:
								have_neighbour = true
						if array[i - 1][  j  ] == 1:
							have_neighbour = true
					
					if LOOK_AT_LEFT:
						if j > 0:
							if array[  i  ][j - 1] == 1:
								have_neighbour = true
				
				if have_neighbour == true:
					if randi() % 100 < chance_to_terrain:
						array[i][j] = 1
		
		if !find_route(array):
			break
		
		array = generated_array
			

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

#class Vector2i:
#	var x : int = 0
#	var y : int = 0
#
#	func _init(var x, var y) -> void:
#		self.x = x
#		self.y = y
#
#	func is_equal_to(var other_vector : Vector2i) -> bool:
#		if other_vector.x == x:
#			if other_vector.y == y:
#				return true
#		return false

func find_route(var array : Array) -> bool:
	var to_check : Array = []
	var checked : Array = []
	var current_element : Vector2 = Vector2(0,0)
	for i in array[0]: # OD
		if i != 1:
			continue
		to_check.append(Vector2(0,i))
		while to_check.size() > 0:
			current_element = to_check.pop_front()
			
			if int(current_element.y) % 2 == 1:
				if (current_element.x > 0 && current_element.y > 0):
					if(array[current_element.x - 1][current_element.y - 1] == 1):
						if !checked.has(Vector2(current_element.x-1,current_element.y-1)):
							to_check.append(Vector2(current_element.x-1,current_element.y-1))
				if (current_element.x > 0):
					if(array[current_element.x - 1][  current_element.y  ] == 1):
						if !checked.has(Vector2(current_element.x-1,current_element.y)):
							to_check.append(Vector2(current_element.x-1,current_element.y))
				if (current_element.x > 0 && current_element.y < array.size() - 1):
					if(array[current_element.x - 1][current_element.y + 1] == 1):
						if !checked.has(Vector2(current_element.x-1,current_element.y+1)):
							to_check.append(Vector2(current_element.x-1,current_element.y+1))
				if (current_element.y > 0):
					if(array[  current_element.x  ][current_element.y - 1] == 1):
						if !checked.has(Vector2(current_element.x,current_element.y-1)):
							to_check.append(Vector2(current_element.x,current_element.y-1))
				if (current_element.y < array.size() - 1):
					if(array[  current_element.x  ][current_element.y + 1] == 1):
						if !checked.has(Vector2(current_element.x,current_element.y+1)):
							to_check.append(Vector2(current_element.x,current_element.y+1))
				if (current_element.x < array.size() - 1):
					if(array[current_element.x + 1][  current_element.y  ] == 1):
						if !checked.has(Vector2(current_element.x+1,current_element.y)):
							to_check.append(Vector2(current_element.x+1,current_element.y))
				
				
#					array[i - 1][j - 1] == 1
#					array[i - 1][  j  ] == 1
#					array[i - 1][j + 1] == 1
#					array[  i  ][j - 1] == 1
#					array[  i  ][j + 1] == 1
#					array[i + 1][  j  ] == 1
			else:
				if (current_element.x < array.size() - 1 && current_element.y > 0):
					if(array[current_element.x + 1][current_element.y - 1] == 1):
						if !checked.has(Vector2(current_element.x+1,current_element.y-1)):
							to_check.append(Vector2(current_element.x+1,current_element.y-1))
				if (current_element.x  < array.size() - 1):
					if(array[current_element.x + 1][  current_element.y  ] == 1):
						if !checked.has(Vector2(current_element.x+1,current_element.y)):
							to_check.append(Vector2(current_element.x+1,current_element.y))
				if (current_element.x < array.size() - 1 && current_element.y < array.size() - 1):
					if(array[current_element.x + 1][current_element.y + 1] == 1):
						if !checked.has(Vector2(current_element.x+1,current_element.y+1)):
							to_check.append(Vector2(current_element.x+1,current_element.y+1))
				if (current_element.y > 0):
					if(array[  current_element.x  ][current_element.y - 1] == 1):
						if !checked.has(Vector2(current_element.x,current_element.y-1)):
							to_check.append(Vector2(current_element.x,current_element.y-1))
				if (current_element.y < array.size() - 1):
					if(array[  current_element.x  ][current_element.y + 1] == 1):
						if !checked.has(Vector2(current_element.x,current_element.y+1)):
							to_check.append(Vector2(current_element.x,current_element.y+1))
				if (current_element.x > 0):
					if(array[current_element.x - 1][  current_element.y  ] == 1):
						if !checked.has(Vector2(current_element.x-1,current_element.y)):
							to_check.append(Vector2(current_element.x-1,current_element.y))
				
#					array[i + 1][j - 1] == 1
#					array[i + 1][  j  ] == 1
#					array[i + 1][j + 1] == 1
#					array[  i  ][j - 1] == 1
#					array[  i  ][j + 1] == 1
#					array[i - 1][  j  ] == 1
				
				
			checked.append(current_element)
				
				
#		for j in checked:
#			if 
			
			
		to_check = []
		checked = []
		
	return true

	
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
	
