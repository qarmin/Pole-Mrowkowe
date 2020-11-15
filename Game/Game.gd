extends Spatial

var current_terrain_overlay_hex_name : String = ""
var current_unit_overlay_hex_name : String = ""

var selected_ant : Node = null
var selected_hex : Node = null

var terrain_overlay_node : Node = preload("res://Overlay/TerrainOverlay.tscn").instance()
var unit_overlay_node : Node = preload("res://Overlay/UnitOverlay.tscn").instance()

var current_

func _ready() -> void:
	$Overlays.add_child(terrain_overlay_node)
	$Overlays.add_child(unit_overlay_node)
	for i in $Overlays.get_children():
		i.hide()
	
	connect_clickable_signals()
	pass


func connect_clickable_signals() -> void:
	# Łączenie każdego pola oraz mrówki na mapie z funkcją wyświelającą 
	for single_hex in $Map.get_children():
		assert(single_hex.get_name().begins_with("SingleHex"))
		assert(single_hex.connect("hex_clicked", self, "hex_clicked") == OK)
		for thing in single_hex.get_children():
			if ! thing.get_name().begins_with("Ant"):
				continue
			assert(thing.connect("ant_clicked", self, "ant_clicked") == OK)


func ant_clicked(ant: AntBase) -> void:
	var parent_name : String = ant.get_parent().get_name()
#	print("Ant " + parent_name + "/" + ant.get_name() + " was clicked and this was handled!")
	if parent_name == current_unit_overlay_hex_name:
		unit_overlay_node.stop()
		current_unit_overlay_hex_name = ""
		selected_ant = null
		return
	# Hide terrain overlay
	terrain_overlay_node.stop()
	current_terrain_overlay_hex_name = ""
	selected_hex = null
		
	unit_overlay_node.set_translation(ant.get_translation() + ant.get_parent().get_translation())
	unit_overlay_node.set_scale(ant.get_scale())
	unit_overlay_node.reset()
	unit_overlay_node.start()
	current_unit_overlay_hex_name = parent_name
	selected_ant = ant


func hex_clicked(hex: SingleHex) -> void:
#	print("Hex " + hex.get_name() + " was clicked and this was handled!")
	if hex.get_name() == current_terrain_overlay_hex_name:
		terrain_overlay_node.stop()
		current_terrain_overlay_hex_name = ""
		selected_hex = null
		return
	# Hide unit overlay
	unit_overlay_node.stop()
	current_unit_overlay_hex_name = ""
	selected_ant = null
		
	terrain_overlay_node.set_translation(hex.get_translation())
	terrain_overlay_node.set_scale(hex.get_scale())
	terrain_overlay_node.reset()
	terrain_overlay_node.start()
	current_terrain_overlay_hex_name = hex.get_name()
	selected_hex = hex
