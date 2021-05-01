extends Control

var building_icon : Array = [
	"res://HUD/BuildingMenu/Anthill.png",
	"res://HUD/BuildingMenu/Farm.png",
	"res://HUD/BuildingMenu/Sawmill.png",
	"res://HUD/BuildingMenu/Anthill.png",
	"res://HUD/BuildingMenu/Anthill.png",
	"res://HUD/BuildingMenu/Anthill.png",	
	]
var types_of_buildings : Array = [
	Buildings.TYPES_OF_BUILDINGS.ANTHILL,
	Buildings.TYPES_OF_BUILDINGS.FARM,
	Buildings.TYPES_OF_BUILDINGS.SAWMILL,
]
	
var single_building_nodes : Array = []

func _ready() -> void:
	initialize_gui()

func initialize_gui() -> void:
	
	for i in range(6):
		var node : Node = find_node("Building" + str(i + 1)).get_node("VBox")
		single_building_nodes.append(node)
		node.get_node("AspectRatioContainer/Icon").set_texture(load(building_icon[i]))

func update_buildings_info(user_resources : Dictionary, buildings : Dictionary) -> void:
	for building in Buildings.buildings_types:
		var name : String = Buildings.get_bulding_name(building)
		var index : int = types_of_buildings.find(building)
		assert(index != -1) # This type must exists
		
		var downgrade_button : Control = single_building_nodes[index].find_node("Downgrade")
		var upgrade_button : Control = single_building_nodes[index].find_node("Upgrade")
		var _icon : Control = single_building_nodes[index].find_node("icon")
		
		
		# HINT should contains:
		# Upgrade - only shows when upgrade is available:
		## "Upgrade - 10G, 15W, 14F"
		## "Usage - 10G, 15W, 14F"
		## "Production - 15G, 20W, 40F" # If productions of
		
		# Downgrade - shows same thing, but dowgrade should be ~80% of value of update
		
		# Icon, only production and usage
		
		# TODO update hints, Upgrade button etc.
		# TODO - hints with how much costs buildings
		# TODO - if not enough resources, just hide button
		var cloned_user_resources : Dictionary = user_resources.duplicate(true)
		if building in buildings.keys(): 
			var level : int = buildings[building]["level"]
			name += " Level " + str(level)
			downgrade_button.show()
			
			if level == 3:
				 upgrade_button.hide()
			else:
				SingleMap.add_resources(cloned_user_resources, Buildings.get_building_to_build(building, level + 1))
				if SingleMap.are_all_resources_positive(cloned_user_resources):
					upgrade_button.show()
		else:
			name += " not built"
			downgrade_button.hide()
			
			# TODO if enough resources show upgrade button
			
		single_building_nodes[index].get_node("Name").set_text(name)
