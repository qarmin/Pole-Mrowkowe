extends Spatial

var rotation_speed: float = 0.4

func _process(delta: float) -> void:
	rotate(Vector3(0, 1, 0).normalized(), rotation_speed * delta)
