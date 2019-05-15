extends MeshInstance
class_name SingleHex

enum types_of_hex { DEFAULT, LAKE, MOUNTAIN}

#var self_position : Vector3
var buildings : Dictionary = { "House": false}
var owner_id : int = -1 # no_owner for now 
var production : PoolIntArray = [1,2,3,4] # Kolejność znajduje się w Prices
var type_of_hex : int = types_of_hex.DEFAULT
var soldier_can_get_through : bool = true

## Nie wiem czy to będzie potrzebne
var have_soldier : bool = false


func _ready() -> void: 
## Sprawdzanie mapy
	for i in get_children():
		var temp_name : String = i.get_name()
		if temp_name.to_upper().begins_with("ENV"):
			temp_name = temp_name.substr(3, temp_name.length())
			if temp_name.begins_with("Lake"):
				type_of_hex = types_of_hex.LAKE
				soldier_can_get_through = false
	
func add_soldier() -> void:
	have_soldier = true
	
func remove_soldier() -> void:
	have_soldier = false

func build(building : String) -> void: # Pierwsza Litera zawsze duża
	if buildings.has(building):
		print("Found Building")
	else:
		printerr("Not found building " + building)