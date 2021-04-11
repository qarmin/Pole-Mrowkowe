extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_resources(dictionary : Dictionary) -> void:
	$HBox/Gold/Label.set_text(str(dictionary["gold"]))
	$HBox/Water/Label.set_text(str(dictionary["water"]))
	$HBox/Food/Label.set_text(str(dictionary["food"]))
	$HBox/Wood/Label.set_text(str(dictionary["wood"]))
