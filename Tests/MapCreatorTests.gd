extends Spatial


func _ready() -> void:
	test_create_map()
	pass

func test_create_map():
	MapCreator.generate_partial_map(Vector2(10,20),31)
	MapCreator.populate_random_map(100)
	add_child(load("GeneratedMap.tscn").instance())
