extends Spatial


func _ready() -> void:
	test_create_map()
	pass

func test_create_map():
	var map : Spatial
	map = MapCreator.generate_partial_map(Vector2(10,10),90)
	MapCreator.populate_random_map(map,80)
	add_child(map)
	MapCreator.save_map(map)
