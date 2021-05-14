extends Control

signal upgrade_clicked
signal downgrade_clicked

signal create_unit_clicked

var building_icon: Array = [
	"res://HUD/BuildingMenu/Anthill.png",
	"res://HUD/BuildingMenu/Farm.png",
	"res://HUD/BuildingMenu/Sawmill.png",
	"res://HUD/BuildingMenu/Barracks.png",
	"res://HUD/BuildingMenu/Pile.png",
	"res://HUD/BuildingMenu/GoldMine.png",
]
var types_of_buildings: Array = [
	Buildings.TYPES_OF_BUILDINGS.ANTHILL,
	Buildings.TYPES_OF_BUILDINGS.FARM,
	Buildings.TYPES_OF_BUILDINGS.SAWMILL,
	Buildings.TYPES_OF_BUILDINGS.BARRACKS,
	Buildings.TYPES_OF_BUILDINGS.PILE,
	Buildings.TYPES_OF_BUILDINGS.GOLD_MINE,
]
var units_icon: Array = [
	"res://HUD/UnitsIcons/Worker.png",
	"res://HUD/UnitsIcons/Soldier.png",
	"res://HUD/UnitsIcons/Flying.png",
]
var types_of_units: Array = [
	Units.TYPES_OF_ANTS.WORKER,
	Units.TYPES_OF_ANTS.SOLDIER,
	Units.TYPES_OF_ANTS.FLYING,
]

var single_building_nodes: Array = []
var single_unit_nodes: Array = []


func _ready() -> void:
	initialize_gui()


func initialize_gui() -> void:
	for i in range(Buildings.NUMBER_OF_BUILDINGS):
		var node: Node = find_node("Building" + str(i + 1)).get_node("VBox")
		assert(node != null)
		single_building_nodes.append(node)
		node.get_node("AspectRatioContainer/Icon").set_texture(load(building_icon[i]))

		# Connect downgrade and upgrade buttons
		assert(node.find_node("Upgrade").connect("button_up", self, "handle_upgrade_click", [types_of_buildings[i]]) == OK)
		assert(node.find_node("Downgrade").connect("button_up", self, "handle_downgrade_click", [types_of_buildings[i]]) == OK)

	for i in range(Units.TYPES_OF_ANTS.ANT_MAX):
		var node: Node = find_node("Unit" + str(i + 1)).get_node("VBox")
		assert(node != null)
		single_unit_nodes.append(node)
		node.get_node("AspectRatioContainer/Icon").set_texture(load(units_icon[i]))

		# Connect downgrade and upgrade buttons
		assert(node.find_node("CreateUnit").connect("button_up", self, "handle_create_unit_click", [types_of_units[i]]) == OK)


func handle_create_unit_click(type_of_unit: int) -> void:
	Units.validate_type(type_of_unit)
	emit_signal("create_unit_clicked", type_of_unit)
	assert(get_signal_connection_list("create_unit_clicked").size() > 0)


func handle_upgrade_click(type_of_building: int) -> void:
	Buildings.validate_building(type_of_building)
	emit_signal("upgrade_clicked", type_of_building)
	assert(get_signal_connection_list("upgrade_clicked").size() > 0)


func handle_downgrade_click(type_of_building: int) -> void:
	Buildings.validate_building(type_of_building)
	emit_signal("downgrade_clicked", type_of_building)
	assert(get_signal_connection_list("downgrade_clicked").size() > 0)


func update_buildings_info(user_resources: Dictionary, buildings: Dictionary, coordinates: Vector2j, single_map: SingleMap) -> void:
	update_units_info(user_resources, buildings, coordinates, single_map)
	for building in Buildings.buildings_types:
		var name: String = Buildings.get_bulding_name(building)
		var index: int = types_of_buildings.find(building)
		assert(index != -1)  # This type must exists

		var downgrade_button: Control = single_building_nodes[index].find_node("Downgrade")
		var upgrade_button: Control = single_building_nodes[index].find_node("Upgrade")
		var icon: Control = single_building_nodes[index].find_node("Icon")
		assert(icon != null)
		assert(upgrade_button != null)
		assert(downgrade_button != null)

		var upgrade_hint_text: String = ""
		var downgrade_hint_text: String = ""
		var icon_hint_text: String = ""
		var cloned_user_resources: Dictionary = user_resources.duplicate(false)
		if building in buildings.keys():  #Budynek istnieje i zawsze ma level >= 1
			var level: int = buildings[building]["level"]
			name += " Level " + str(level)

			### Icon button
			var usage: Dictionary = Buildings.get_building_usage(building, level)
			var production: Dictionary = Buildings.get_building_production(building, level)

			icon_hint_text += "Production:  " + Resources.string_resources_short(production) + "\n"
			icon_hint_text += "Usage:  " + Resources.string_resources_short(usage)

			icon.set_tooltip(icon_hint_text)

			### Downgrade button
			if level == 1 && building == Buildings.TYPES_OF_BUILDINGS.ANTHILL:  # Cannot destroy level 1 Anthill
				downgrade_button.hide()
			else:
				downgrade_button.show()
				downgrade_button.set_disabled(false)

				var to_upgrade: Dictionary = Buildings.get_building_to_build(building, level)
				var usage_before: Dictionary = Resources.get_resources()
				var production_before: Dictionary = Resources.get_resources()

				# Level 0 have production and usage set to 0, but others no
				if level > 1:
					usage_before = Buildings.get_building_usage(building, level - 1)
					production_before = Buildings.get_building_production(building, level - 1)

				Resources.scale_resources(to_upgrade, Buildings.DOWNGRADE_COST)
				if level > 1:
					downgrade_hint_text += "Downgrade Building\n"
				else:
					downgrade_hint_text += "Removing Building\n"
				downgrade_hint_text += "To build:  " + Resources.string_resources_short(to_upgrade) + "\n"
				downgrade_hint_text += "Production:  " + Resources.string_resources_short(production_before) + "\n"
				downgrade_hint_text += "Usage:  " + Resources.string_resources_short(usage_before)

				downgrade_button.set_tooltip(downgrade_hint_text)

			### Upgrade button
			if level == 3:
				upgrade_button.hide()
			else:
				upgrade_button.show()
				upgrade_button.set_disabled(false)
				Resources.remove_resources(cloned_user_resources, Buildings.get_building_to_build(building, level + 1))

				if !Resources.are_all_resources_positive(cloned_user_resources):
					upgrade_button.set_disabled(true)
					upgrade_hint_text += "YOU DON'T HAVE ENOUGH RESOURCES!\n"

				var to_upgrade: Dictionary = Buildings.get_building_to_build(building, level + 1)
				var usage_later: Dictionary = Buildings.get_building_usage(building, level + 1)
				var production_later: Dictionary = Buildings.get_building_production(building, level + 1)

				upgrade_hint_text += "Upgrade Building\n"
				upgrade_hint_text += "To build:  " + Resources.string_resources_short(to_upgrade) + "\n"
				upgrade_hint_text += "Production:  " + Resources.string_resources_short(production_later) + "\n"
				upgrade_hint_text += "Usage:  " + Resources.string_resources_short(usage_later)

				upgrade_button.set_tooltip(upgrade_hint_text)

		else:  # Level is always 0
			name += " not built"

			# Icon
			icon_hint_text += "Production:  " + Resources.string_resources_short(Resources.get_resources()) + "\n"
			icon_hint_text += "Usage:  " + Resources.string_resources_short(Resources.get_resources())

			icon.set_tooltip(icon_hint_text)

			# Downgrade
			downgrade_button.hide()
			if building == Buildings.TYPES_OF_BUILDINGS.ANTHILL:  # Can't built second anthill
				upgrade_button.hide()
				icon.set_tooltip("CAN'T BUILD SECOND ANTIHLL!")
			else:
				upgrade_button.show()
				upgrade_button.set_disabled(false)

				Resources.remove_resources(cloned_user_resources, Buildings.get_building_to_build(building, 1))
				if !Resources.are_all_resources_positive(cloned_user_resources):
					upgrade_button.set_disabled(true)
					upgrade_hint_text += "YOU DON'T HAVE ENOUGH RESOURCES!\n"
				if single_map.building_get_place_for_build(coordinates) == -1:
					upgrade_button.set_disabled(true)
					upgrade_hint_text += "YOU CAN BUILD MAX 4 BUILDINGS ON HEX!\n"

				var to_upgrade: Dictionary = Buildings.get_building_to_build(building, 1)
				var usage_later: Dictionary = Buildings.get_building_usage(building, 1)
				var production_later: Dictionary = Buildings.get_building_production(building, 1)

				upgrade_hint_text += "Create building\n"
				upgrade_hint_text += "To build:  " + Resources.string_resources_short(to_upgrade) + "\n"
				upgrade_hint_text += "Production:  " + Resources.string_resources_short(production_later) + "\n"
				upgrade_hint_text += "Usage:  " + Resources.string_resources_short(usage_later)

				upgrade_button.set_tooltip(upgrade_hint_text)

		single_building_nodes[index].get_node("Name").set_text(name)


func update_units_info(user_resources: Dictionary, buildings: Dictionary, coordinates: Vector2j, single_map: SingleMap) -> void:
	for unit in Units.units_types:
		var name: String = Units.get_unit_name(unit)
		var index: int = types_of_units.find(unit)
		assert(index != -1)  # This type must exists

		var usage: Dictionary = Units.get_unit_usage(unit, 1)
		var to_build: Dictionary = Units.get_unit_to_build(unit, 1)

		var create_unit: TextureButton = single_unit_nodes[index].find_node("CreateUnit")
		var icon: Control = single_unit_nodes[index].find_node("Icon")
		assert(icon != null)
		assert(create_unit != null)

		var create_unit_hint_text: String = ""
		var icon_hint_text: String = ""

		var cloned_user_resources: Dictionary = user_resources.duplicate(false)

		if !single_map.units[coordinates.y][coordinates.x].empty():
			if single_map.units[coordinates.y][coordinates.x]["type"] == index:
				icon_hint_text = "Usage:  " + Resources.string_resources_short(usage)
				create_unit.hide()
			else:
				create_unit.show()
				create_unit.set_disabled(true)
				create_unit_hint_text = "ALREADY THERE IS ANT IN FIELD!"
		else:
			create_unit.show()
			if buildings.has(Buildings.TYPES_OF_BUILDINGS.BARRACKS) || buildings.has(Buildings.TYPES_OF_BUILDINGS.ANTHILL):
				Resources.remove_resources(cloned_user_resources, to_build)
				if Resources.are_all_resources_positive(cloned_user_resources):
					create_unit.set_disabled(false)
					create_unit_hint_text = "Create Unit\n"
					create_unit_hint_text += "Usage:  " + Resources.string_resources_short(usage) + "\n"
					create_unit_hint_text += "To build:  " + Resources.string_resources_short(to_build)
				else:
					create_unit.set_disabled(true)
					create_unit_hint_text = "YOU DON'T HAVE ENOUGH OF RESOURCES"
			else:
				create_unit.set_disabled(true)
				create_unit_hint_text = "YOU CAN ONLY CREATE UNIT ON FIELD WITH ANTHILL OR BARRACKS!"

		icon.set_tooltip(icon_hint_text)
		create_unit.set_tooltip(create_unit_hint_text)

		single_unit_nodes[index].get_node("Name").set_text(name)



