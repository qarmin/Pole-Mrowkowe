extends Node

var file_name: String = "save_file"
var file_name_extension: String = ".sav"
var file_handler: File = File.new()
var create_file_backup: bool = false  #Tworzy kopie savefile.sav savefile.backup.sav savefile.backup2.sav


## Zapisuje mapę do pliku jako PackedScene
## Dostępne jest to tylko do celów testowych
func save_map_as_packed_scene(single_map: SingleMap) -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(single_map.map)

	if ResourceSaver.save("res://GeneratedMap.tscn", packed_scene) != OK:
		printerr("Nie powiodła się próba zapisu mapy")
		return



func save_map_as_text(single_map: SingleMap, slot : int = 0) -> void:
	assert(slot == 0 || slot == 100) # 100 to wartość do debugowania
	
	var file_to_save: File = File.new()
	if file_to_save.open("res://save_slot" +str(slot) + ".txt", File.WRITE) != OK:
		push_error("Nie udało się utworzyć pliku do zapisu")
		return

	file_to_save.store_8(1)  # Wersja savu, może być przydatna przy wczytywaniu

	file_to_save.store_64(single_map.size.x)
	file_to_save.store_64(single_map.size.y)
#	file_to_save.store_var(single_map.size,true)
	file_to_save.store_var(single_map.fields,true)
	file_to_save.store_var(single_map.units,true)
	file_to_save.store_var(single_map.buildings,true)
	file_to_save.store_var(single_map.nature,true)

	file_to_save.close()
	pass

func load_map_from_text(slot : int =0) -> SingleMap:
	var single_map : SingleMap = SingleMap.new()
	assert(slot == 0 || slot == 100) # 100 to wartość do debugowania
	
	var file_to_save: File = File.new()
	if file_to_save.open("res://save_slot" +str(slot) + ".txt", File.READ) != OK:
		push_error("Nie udało się utworzyć pliku do zapisu")
		assert(false)
		return single_map
	
	var version : int = file_to_save.get_8()
	
	if version == 1:
	
		var size_x :  = file_to_save.get_64()
		var size_y :  = file_to_save.get_64()
	#	var size : Vector2j = file_to_save.get_var()
		var fields : Array = file_to_save.get_var()
		var units : Array = file_to_save.get_var()
		var buildings : Array = file_to_save.get_var()
		var nature : Array = file_to_save.get_var()
		
		single_map.set_size(Vector2j.new(size_x,size_y))
		single_map.fields = fields
		single_map.units = units
		single_map.buildings = buildings
		single_map.nature = nature
	
	file_to_save.close()
	
	return single_map
	pass
