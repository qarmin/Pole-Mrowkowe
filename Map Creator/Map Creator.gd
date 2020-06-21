extends Spatial

export (PackedScene) var SingleHex
export (PackedScene) var Ant

const CREATE_EMPTY : bool = false
const ANTS : bool = true
const ANT_CHANCE : int = 100

const NUMBER_OF_HEX : Vector2 = Vector2(3,3)
const SINGLE_HEX_DIMENSION : Vector2 = Vector2(1.732,1.5)
var START_POSITION : Vector3
const NODE_BASE_NAME : String = "SingleHex"
#var hex_array : Array

func _ready() -> void:
	
	randomize() # Bez tego za każdym razem wychdzą takie same wyniki randi()
	
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
			print(SH.get_scene_instance_load_placeholder())
			SH.set_scene_instance_load_placeholder(true)
			get_node("Map").add_child(SH)
			SH.set_owner(get_node("Map"))
			if !CREATE_EMPTY && ANTS:
				if randi() % 100 < ANT_CHANCE:
					var AN : Spatial = Ant.instance()#PackedScene.GEN_EDIT_STATE_DISABLED) # Zostało z testów autozapisywania mapy, na chwilę obecną robię to poprzez Remote w drzewie sceny przy ZATRZYMANEJ grze(jest to wymagane bo inaczej nie działa)
					AN.translation = Vector3(0.0,1.0,0.0)
					AN.get_node("Outfit").set_surface_material(0,mat)
					SH.add_child(AN)
					#AN.set_owner(SH)


	var packed_scene = PackedScene.new()
	packed_scene.pack(get_node("Map"))
	if(ResourceSaver.save("res://Terrain/Map.tscn", packed_scene)):
		printerr("Nie powiodła się próba zapisu mapy")
		
#func _process(delta: float) -> void:
#	print("AAA")

