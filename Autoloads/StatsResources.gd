extends Node

var resources: Array = ["wood", "gold", "food"]


func get_resources() -> Dictionary:
	return {"wood": 0, "gold": 0, "food": 0}


func validate_resources(res: Dictionary) -> void:
	assert(res.size() == resources.size())
	assert(res.has_all(resources))


func normalize_resources(res: Dictionary) -> void:
	validate_resources(res)

	for i in res.keys():
		if res[i] < 0:
			res[i] = 0


func string_resources_short(res: Dictionary) -> String:
	validate_resources(res)
	var text: String = ""
	text += str(res["gold"]) + "G "
	text += str(res["wood"]) + "W "
	text += str(res["food"]) + "F "

	return text


func scale_resources(res: Dictionary, scalar: float):
	for key in res.keys():
		res[key] = int(res[key] * scalar)


# Adds resources from base dictionary
func add_resources(base_dict: Dictionary, to_add_dict: Dictionary) -> void:
	validate_resources(base_dict)
	validate_resources(to_add_dict)
	for key in base_dict.keys():
		base_dict[key] += to_add_dict[key]


# Remove resources from base dictionary
func remove_resources(base_dict: Dictionary, to_add_dict: Dictionary) -> void:
	validate_resources(base_dict)
	validate_resources(to_add_dict)
	for key in base_dict.keys():
		base_dict[key] -= to_add_dict[key]


# Only checks if some of resources are negative
func are_all_resources_positive(dict: Dictionary) -> bool:
	validate_resources(dict)
	for i in dict.values():
		if i < 0:
			return false
	return true
