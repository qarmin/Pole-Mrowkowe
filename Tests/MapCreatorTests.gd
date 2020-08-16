extends Spatial


func _ready() -> void:
	test_create_map()
	pass


func test_create_map():
	var single_map: SingleMap = SingleMap.new()

#	MapCreator.create_full_map(single_map, Vector2j.new(30, 30))
	MapCreator.create_partial_map(single_map, Vector2j.new(4,4), 70)
	MapCreator.center_map(single_map)
#	MapCreator.populate_map_fully(single_map, 4)
	MapCreator.populate_map_randomly(single_map, 50)
	PreviewGenerator.generate_preview_image(single_map)
	add_child(single_map.map)
	$Camera.set_size(single_map.size.y * MapCreator.SINGLE_HEX_DIMENSION.y * 0.75 + 0.25 * MapCreator.SINGLE_HEX_DIMENSION.y)
	MapCreator.save_map(single_map)
