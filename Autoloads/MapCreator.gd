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
	
	
func generate_map(var hex_number : Vector2, var number_of_players : int = GameSettings.MAX_TEAMS) -> void:
	
	var START_POSITION : Vector3
	
	## To tylko przybliżenie, nie chce mi się dokładnie środka wyznaczać
	START_POSITION = Vector3(0,0,0) #Vector3(-hex_number[0] * SINGLE_HEX_DIMENSION[0] / 2.0,0.0,-hex_number[1] * SINGLE_HEX_DIMENSION[1] / 2.0)
	#START_POSITION += Vector3(SINGLE_HEX_DIMENSION[0]/4.0,0.0,SINGLE_HEX_DIMENSION[0]/2.0) 

	
	var map : Spatial = Spatial.new()
	map.set_name("Map")
	
	for i in hex_number.x:
		for j in hex_number.y:
			var SH : MeshInstance = SingleHex.instance()
			SH.translation = START_POSITION + Vector3(j*SINGLE_HEX_DIMENSION.x,randf(),i*SINGLE_HEX_DIMENSION.y)
			if i%2 == 1:
				SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x,0,0)
			SH.name = NODE_BASE_NAME + str(i * hex_number.y + j)
			var mat : SpatialMaterial = texture_base
				
			SH.set_surface_material(0,mat)
			map.add_child(SH)
			SH.set_owner(map)

	map.set_translation(Vector3(-hex_number.y * SINGLE_HEX_DIMENSION.x / 2.0,0,-hex_number.x * SINGLE_HEX_DIMENSION.y / 2.0)) # Wyrównuje 
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(map)
#	if(ResourceSaver.save("user://GeneratedMap.tscn", packed_scene) != OK):
	if(ResourceSaver.save("res://GeneratedMap.tscn", packed_scene,ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS) != OK):
		printerr("Nie powiodła się próba zapisu mapy")
	map.queue_free()
	
func populate_random_map(var ant_chance : int = 100, var number_of_players : int = GameSettings.MAX_TEAMS) -> void:
	assert(number_of_players <= GameSettings.MAX_TEAMS && number_of_players > 0)
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
	
