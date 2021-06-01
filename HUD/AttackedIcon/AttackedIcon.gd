extends Sprite3D


func _ready():
	$AnimationPlayer.play("SIze")
	assert($AnimationPlayer.connect("animation_finished", self, "remove") == OK)


func remove(_unused) -> void:
	queue_free()
