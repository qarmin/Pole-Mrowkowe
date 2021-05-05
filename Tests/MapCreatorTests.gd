extends Spatial


func _ready() -> void:
	test_create_map()
	pass


## Tworzy testowo mapę i wyświetla ją i zapisuje
func test_create_map():
	var single_map: SingleMap = SingleMap.new()

	MapCreator.create_map(single_map, Vector2j.new(3, 3), 20)
#	MapCreator.populate_map_realistically(single_map, 4)
	MapCreator.populate_map_randomly(single_map, 50)
	MapCreator.create_3d_map(single_map)
#	PreviewGenerator.generate_preview_image(single_map)
	add_child(single_map.map)
	$Camera.set_size(single_map.size.y * MapCreator.SINGLE_HEX_DIMENSION.y * 0.75 + 0.25 * MapCreator.SINGLE_HEX_DIMENSION.y)
	SaveSystem.save_map_as_packed_scene(single_map)
	SaveSystem.save_map_as_text(single_map)
