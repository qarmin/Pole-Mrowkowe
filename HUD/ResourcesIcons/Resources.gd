extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_resources(have_resources : Dictionary, end_turn_resources : Dictionary) -> void:
	$HBox/Gold/Label.set_text(str(have_resources["gold"]) + " (+" + str(end_turn_resources["gold"]) + ")")
	$HBox/Water/Label.set_text(str(have_resources["water"]) + " (+" + str(end_turn_resources["water"]) + ")")
	$HBox/Food/Label.set_text(str(have_resources["food"]) + " (+" + str(end_turn_resources["food"]) + ")")
	$HBox/Wood/Label.set_text(str(have_resources["wood"]) + " (+" + str(end_turn_resources["wood"]) + ")")
