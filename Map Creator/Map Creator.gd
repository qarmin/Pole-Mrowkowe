extends Spatial

export (PackedScene) var SingleHex
export (PackedScene) var Ant

const CREATE_EMPTY : bool = true

const NUMBER_OF_HEX : Vector2 = Vector2(3,3)
const SINGLE_HEX_DIMENSION : Vector2 = Vector2(1.732,1.5)
var START_POSITION : Vector3
const NODE_BASE_NAME : String = "SingleHex"
#var hex_array : Array

func _ready() -> void:
	## To tylko przybliżenie, nie chce mi się dokładnie środka wyznaczać
	START_POSITION = Vector3(-NUMBER_OF_HEX[0] * SINGLE_HEX_DIMENSION[0] / 2.0,0.0,-NUMBER_OF_HEX[1] * SINGLE_HEX_DIMENSION[1] / 2.0)
	START_POSITION += Vector3(SINGLE_HEX_DIMENSION[0]/4.0,0.0,SINGLE_HEX_DIMENSION[0]/2.0) 

	var Map : Spatial = Spatial.new()
	Map.name = "Map"
	add_child(Map)
	
	assert(GameSettings.MAX_TEAMS == 4)
	
	var texture_array : Array = [	load("res://Terrain/SingleHex/SingleHexTEAM1.tres"),
									load("res://Terrain/SingleHex/SingleHexTEAM2.tres"),
									load("res://Terrain/SingleHex/SingleHexTEAM3.tres"),
									load("res://Terrain/SingleHex/SingleHexTEAM4.tres")]
	
	for i in NUMBER_OF_HEX.x:
		for j in NUMBER_OF_HEX.y:
			var SH : MeshInstance = SingleHex.instance()#PackedScene.GEN_EDIT_STATE_MAIN)#GEN_EDIT_STATE_INSTANCE)
			SH.translation = START_POSITION + Vector3(j*SINGLE_HEX_DIMENSION.x,randf(),i*SINGLE_HEX_DIMENSION.y)
			if i%2 == 1:
				SH.translation += Vector3(0.5 * SINGLE_HEX_DIMENSION.x,0,0)
			SH.name = NODE_BASE_NAME + str(i * NUMBER_OF_HEX.y + j)
			var mat : SpatialMaterial = SpatialMaterial.new()
			if CREATE_EMPTY:
				mat = load("res://Terrain/SingleHex/SingleHexBase.tres")
			else:
				if (randi() % texture_array.size()) == 0:
					mat = load("res://Terrain/SingleHex/SingleHexBase.tres")
				else:
					mat = texture_array[randi() % texture_array.size()]
			SH.set_surface_material(0,mat)
			get_node("Map").add_child(SH)
			SH.set_owner(get_node("Map"))
#			if randi() % 100 < 40:
#				var AN : MeshInstance = Ant.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
#				AN.translation = SH.translation + Vector3(0.0,1.0,0.0)
#				SH.add_child(AN)


	var packed_scene = PackedScene.new()
	packed_scene.pack(get_node("Map"))
	if(ResourceSaver.save("res://Terrain/Map.tscn", packed_scene)):
		printerr("Nie powiodła się próba zapisu mapy")
		
#func _process(delta: float) -> void:
#	print("AAA")

