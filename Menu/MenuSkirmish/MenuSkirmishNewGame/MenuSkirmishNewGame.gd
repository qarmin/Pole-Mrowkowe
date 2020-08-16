extends Control

var created_map : SingleMap = SingleMap.new()

var player_name : String = ""
var size_of_map : Vector2j = Vector2j.new(0,0)
var number_of_cpu_players : int
var chance_to_terrain : int


func _on_Generate_Map_button_up() -> void:
	read_values()
	
	
	# TODO - pobierz wartości 
	var single_map: SingleMap = SingleMap.new()
	var image_texture : ImageTexture = ImageTexture.new()
#	MapCreator.create_full_map(single_map,Vector2j.new(30,30))
	while true:
		MapCreator.create_map(single_map,Vector2j.new(size_of_map.x,size_of_map.y),chance_to_terrain)
		if MapCreator.populate_map_realistically(single_map):
			break
		single_map.reset()
	PreviewGenerator.generate_preview_image(single_map)
	
	image_texture.create_from_image(single_map.preview,0) # Filtrowanie - flaga 4 - tworzy na krańcach dziwne "cienie"
	
	$Control/Margin/HBox/TextureRect.set_texture(image_texture)
	
	single_map.reset() # TODO - powinno coś robić z tą mapą, bo póki co zalega mi w OrphanNode i muszę ją usuwać za każdym razem
#	created_map.reset()
#	created_map = single_map

func read_values() -> void:
	# TODO - zmienić find_node na może get_node
	size_of_map.x = find_node("MapWidth").get_node("SpinBox").get_value()
	size_of_map.y = find_node("MapHeight").get_node("SpinBox").get_value()
	number_of_cpu_players = find_node("CPUPlayers").get_node("SpinBox").get_value()
	player_name = find_node("PlayerName").get_node("LineEdit").get_text()
	chance_to_terrain = find_node("ChanceOfTerrain").get_node("SpinBox").get_value()
	
	pass
