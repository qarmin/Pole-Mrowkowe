extends Spatial

#var hex_number # Powino się w Autoload GameSettings.gd(Nie jestem do końca jednak tego pewien)
#var SingleHexOwner : PoolIntArray = PoolIntArray([]) # 100 - neutralny, -1 - nieprzypisany

#Testowe dodawanie mrówek na mapie
#export (PackedScene) var Ant

#func _ready() -> void:
# TODO - to nie jest już potrzebne, później należy to usunąć
#	var Single_Hex_texture_array : Array = [load("res://Terrain/SingleHex/SingleHexTEAM1.tres"),
#											load("res://Terrain/SingleHex/SingleHexTEAM2.tres"),
#											load("res://Terrain/SingleHex/SingleHexTEAM3.tres"),
#											load("res://Terrain/SingleHex/SingleHexTEAM4.tres")]
#	var Ant_texture_array : Array = [	load("res://Units/Outfit/OutfitTEAM1.tres"),
#										load("res://Units/Outfit/OutfitTEAM2.tres"),
#										load("res://Units/Outfit/OutfitTEAM3.tres"),
#										load("res://Units/Outfit/OutfitTEAM4.tres")]
#
#	for i in range(0,hex_number):
#		var MI : MeshInstance = get_node("Map/SingleHex" + str(i))
#		## Dodawanie numeru właściciela
#		for j in range(0,Single_Hex_texture_array.size()):
#			if MI.get_surface_material(0) == Single_Hex_texture_array[j]:
#				SingleHexOwner[i] = j
#		if MI.get_surface_material(0) == load("res://Terrain/SingleHex/SingleHexBase.tres"):
#			SingleHexOwner[i] = 100
#
#		for j in MI.get_children():
#			if j.get_name().to_upper().begins_with("ANT"):
#				j.owner_id = SingleHexOwner[i]
#				if SingleHexOwner[i] == 100:
#					printerr("Nie powinno być mrówki na polu neutralnym")
#				else:
#					j.get_node("Outfit").set_surface_material(0,Ant_texture_array[SingleHexOwner[i]])

#	for i in range(0,hex_number): # Sprawdzanie przynależności Hexu do danego rodzaju
#		print(str(i) + ". " + str(SingleHexOwner[i]))
