tool

extends Spatial

var speed: float = 0.25
var rotation_speed: float = 1

func _process(delta: float) -> void:
	rotate(Vector3(0, 1, 0).normalized(), rotation_speed * delta)
