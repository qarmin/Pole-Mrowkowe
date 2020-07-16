extends VBoxContainer

const NUMBER_OF_ALL_MONITORS: int = 18


func _ready() -> void:
	for _i in range(NUMBER_OF_ALL_MONITORS):
		add_child(load("res://Menu/Performance/SinglePerf.tscn").instance())


func _process(_delta) -> void:
	var i = 0
	get_child(i).set_text("FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)))
	i += 1
	get_child(i).set_text("TIME_PROCESS: " + str(Performance.get_monitor(Performance.TIME_PROCESS)))
	i += 1
	get_child(i).set_text("TIME_PHYSICS_PROCESS: " + str(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)))
	i += 1
	get_child(i).set_text("OBJECT_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_COUNT)))
	i += 1
	get_child(i).set_text("OBJECT_RESOURCE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)))
	i += 1
	get_child(i).set_text("OBJECT_NODE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	i += 1
	get_child(i).set_text("OBJECT_ORPHAN_NODE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)))
	i += 1
	get_child(i).set_text("RENDER_OBJECTS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_VERTICES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_MATERIAL_CHANGES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_SHADER_CHANGES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_SURFACE_CHANGES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_DRAW_CALLS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_2D_ITEMS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_2D_DRAW_CALLS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME)))
	i += 1
	get_child(i).set_text("RENDER_VIDEO_MEM_USED: " + str(stepify(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1000000.0, 0.01)) + "MB")
	i += 1
	get_child(i).set_text("RENDER_TEXTURE_MEM_USED: " + str(stepify(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1000000.0, 0.01)) + "MB")
	i += 1
	get_child(i).set_text("RENDER_VERTEX_MEM_USED: " + str(stepify(Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED) / 1000000.0, 0.01)) + "MB")
	i += 1
	assert((i) == NUMBER_OF_ALL_MONITORS)
