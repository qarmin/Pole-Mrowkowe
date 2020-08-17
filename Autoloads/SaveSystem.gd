extends Node

var file_name: String = "save_file"
var file_name_extension: String = ".sav"
var file_handler: File = File.new()
var create_file_backup: bool = false  #Tworzy kopie savefile.sav savefile.backup.sav savefile.backup2.sav


## Zapisuje mapę do pliku jako PackedScene
## Dostępne jest to tylko do celów testowych
func save_map_as_packed_scene(single_map: SingleMap, destroy: bool = false) -> void:
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


func save_map_as_text(single_map: SingleMap) -> void:
	var file_to_save: File = File.new()
	if file_to_save.open("saved_slot1.txt", File.WRITE) != OK:
		push_error("Nie udało się utworzyć pliku do zapisu")

	file_to_save.store_8(1)  # Wersja savu, może być przydatna przy wczytywaniu

	file_to_save.store_var(single_map.size)
	file_to_save.store_var(single_map.fields)
	file_to_save.store_var(single_map.units)

	file_to_save.close()
	pass
