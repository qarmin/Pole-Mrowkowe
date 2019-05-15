extends Node

var resources_number : Dictionary = { "Iron" : 0, "Wood" : 0, "Food" : 0, "Happiness" : 100} 
var action_points : int = 20
var max_action_points : int = 20


func _ready() -> void:
	pass
	
	
func add_an_resource(resource_name : String, added_resources : int) -> void:
	if resources_number.has(resource_name):
		resources_number[resource_name] += added_resources 
	else:
		print("Nie ma takiego zasobu jak " + resource_name)