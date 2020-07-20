extends Spatial


func _ready() -> void:
	test_create_map()
	pass


func test_create_map():
	var single_map: SingleMap = SingleMap.new()

	MapCreator.generate_partial_map(single_map, Vector2(30, 30), 90)
	MapCreator.populate_map(single_map, 4)
	add_child(single_map.map)
	MapCreator.save_map(single_map)
