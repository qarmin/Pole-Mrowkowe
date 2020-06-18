extends VBoxContainer

func _ready():
	for i in range(18):
		add_child(load("res://Menu/Performance/SinglePerf.tscn").instance())

func _process(delta):
	get_child(0).set_text("FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)))
	get_child(1).set_text("TIME_PROCESS: " + str(Performance.get_monitor(Performance.TIME_PROCESS)))
	get_child(2).set_text("TIME_PHYSICS_PROCESS: " + str(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)))
	get_child(3).set_text("OBJECT_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_COUNT)))
	get_child(4).set_text("OBJECT_RESOURCE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)))
	get_child(5).set_text("OBJECT_NODE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	get_child(6).set_text("OBJECT_ORPHAN_NODE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)))
	get_child(7).set_text("RENDER_OBJECTS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME)))
	get_child(8).set_text("RENDER_VERTICES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME)))
	get_child(9).set_text("RENDER_MATERIAL_CHANGES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME)))
	get_child(10).set_text("RENDER_SHADER_CHANGES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME)))
	get_child(11).set_text("RENDER_SURFACE_CHANGES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME)))
	get_child(12).set_text("RENDER_DRAW_CALLS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME)))
	get_child(13).set_text("RENDER_2D_ITEMS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME)))
	get_child(14).set_text("RENDER_2D_DRAW_CALLS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME)))
	get_child(15).set_text("RENDER_VIDEO_MEM_USED: " + str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)))
	get_child(16).set_text("RENDER_TEXTURE_MEM_USED: " + str(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1000000.0) + "MB")
	get_child(17).set_text("RENDER_VERTEX_MEM_USED: " + str(Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED)))
