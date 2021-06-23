extends Control

signal destroy_unit_clicked
signal move_unit_clicked

var move_button: TextureButton

var destroy_button: TextureButton
var icon: TextureRect
var ant_name: Label

var attack_stat: Label
var defense_stat: Label
var ant_stat: Label
var movement_stat: Label

var units_icons: Dictionary = {
	Units.TYPES_OF_ANTS.WORKER: "res://HUD/UnitsIcons/Worker.png",
	Units.TYPES_OF_ANTS.SOLDIER: "res://HUD/UnitsIcons/Soldier.png",
	Units.TYPES_OF_ANTS.FLYING: "res://HUD/UnitsIcons/Flying.png",
}


func _ready() -> void:
	initialize_gui()


func initialize_gui() -> void:
	move_button = find_node("MoveUnit")

	destroy_button = find_node("DestroyUnit")
	icon = find_node("AntIcon")
	ant_name = find_node("AntName")

	attack_stat = find_node("AttackValue")
	defense_stat = find_node("DefenseValue")
	ant_stat = find_node("AntsValue")
	movement_stat = find_node("MovementValue")

	assert(destroy_button != null)
	assert(icon != null)
	assert(ant_name != null)

	assert(attack_stat != null)
	assert(defense_stat != null)
	assert(ant_stat != null)
	assert(movement_stat != null)

	if destroy_button.connect("button_up", self, "handle_remove_unit_click") != OK:
		assert(false)
	if move_button.connect("button_up", self, "handle_move_unit_click") != OK:
		assert(false)


func handle_remove_unit_click() -> void:
	emit_signal("destroy_unit_clicked")
	assert(get_signal_connection_list("destroy_unit_clicked").size() > 0)


func handle_move_unit_click() -> void:
	emit_signal("move_unit_clicked")
	assert(get_signal_connection_list("move_unit_clicked").size() > 0)


func update_units_info(unit: Dictionary, _coordinates: Vector2j, _single_map: SingleMap) -> void:
	var unit_type = unit["type"]

	icon.set_texture(load(units_icons[unit_type]))

	ant_name.set_text(Units.get_unit_name(unit_type))

	var to_build = Units.get_unit_to_build(unit_type, 1)
	Resources.scale_resources(to_build, Units.DOWNGRADE_COST)
	Resources.scale_resources(to_build, unit["stats"]["ants"] / 100.0)
	var usage = Units.get_unit_usage(unit_type, 1)

	var icon_hint: String = "Usage: " + Resources.string_resources_short(usage)
	var destroy_hint: String = "Destroy Ant\nYou will get: " + Resources.string_resources_short(to_build)

	icon.set_tooltip(icon_hint)
	destroy_button.set_tooltip(destroy_hint)

	attack_stat.set_text(str(unit["stats"]["attack"]))
	defense_stat.set_text(str(unit["stats"]["defense"]))
	ant_stat.set_text(str(unit["stats"]["ants"]) + "/" + str(Units.get_default_stats(unit["type"], 1)["ants"]))
	movement_stat.set_text(str(unit["stats"]["number_of_movement"]) + "/" + str(Units.get_default_stats(unit["type"], 1)["number_of_movement"]))

	if unit["stats"]["number_of_movement"] > 0:
		move_button.show()
	else:
		move_button.hide()
