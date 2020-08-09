extends Spatial


func _ready() -> void:
	test_create_map()
	pass


func test_create_map():
	var single_map: SingleMap = SingleMap.new()

#	MapCreator.generate_full_map(single_map, Vector2(30, 30))
	MapCreator.generate_partial_map(single_map, Vector2(10, 10), 70)
	MapCreator.center_map(single_map)
#	MapCreator.populate_map(single_map, 4)
	MapCreator.populate_random_map(single_map, 50)
	PreviewGenerator.generate_preview_image(single_map)
	add_child(single_map.map)
	MapCreator.save_map(single_map)
