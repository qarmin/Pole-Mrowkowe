extends Sprite3D


func _ready():
	$AnimationPlayer.play("SIze")
	$AnimationPlayer.connect("animation_finished", self, "remove")


func remove(_unused) -> void:
	queue_free()
