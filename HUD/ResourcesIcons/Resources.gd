extends Control

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func update_resources(have_resources: Dictionary, end_turn_resources: Dictionary) -> void:
	var positive_symbol: String = ""

	if end_turn_resources["gold"] >= 0:
		positive_symbol = "+"
	else:
		positive_symbol = ""
	$HBox/Gold/Label.set_text(str(have_resources["gold"]) + " (" + positive_symbol + str(end_turn_resources["gold"]) + ")")

	if end_turn_resources["water"] >= 0:
		positive_symbol = "+"
	else:
		positive_symbol = ""
	$HBox/Water/Label.set_text(str(have_resources["water"]) + " (" + positive_symbol + str(end_turn_resources["water"]) + ")")

	if end_turn_resources["food"] >= 0:
		positive_symbol = "+"
	else:
		positive_symbol = ""
	$HBox/Food/Label.set_text(str(have_resources["food"]) + " (" + positive_symbol + str(end_turn_resources["food"]) + ")")

	if end_turn_resources["wood"] >= 0:
		positive_symbol = "+"
	else:
		positive_symbol = ""
	$HBox/Wood/Label.set_text(str(have_resources["wood"]) + " (" + positive_symbol + str(end_turn_resources["wood"]) + ")")
