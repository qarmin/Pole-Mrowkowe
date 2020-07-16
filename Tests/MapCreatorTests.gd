extends Spatial


func _ready() -> void:
	test_create_map()
	pass


func test_create_map():
	var map: Spatial
	var map_array: Array
	map = MapCreator.generate_partial_map(map_array, Vector2(10, 10), 90)
	MapCreator.populate_random_map(map_array, map, 80)
	add_child(map)
	MapCreator.save_map(map_array, map)
