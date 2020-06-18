extends Node

var resources_number : PoolIntArray = [1,1,1,1,1] # Spójrz do PricesAndProduction po więcej szczegółów
var max_action_points : int = 20


func _ready() -> void:
	pass
	
	
func add_an_resource(resource_index : int, added_resources : int) -> void:
	# resource_index biorę z PricesAndProduction
	resources_number[resource_index] += added_resources
