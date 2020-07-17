extends Spatial


func _ready() -> void:
	test_create_map()
	pass


func test_create_map():
	var single_map: SingleMap = SingleMap.new()

	MapCreator.generate_partial_map(single_map, Vector2(20, 5), 40)
	#MapCreator.populate_random_map(single_map, 80)
	MapCreator.populate_map(single_map, 4)
	add_child(single_map.map)
	MapCreator.save_map(single_map)
