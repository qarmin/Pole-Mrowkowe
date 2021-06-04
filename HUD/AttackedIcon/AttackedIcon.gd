extends Sprite3D


func show_icon(attacker_defeated: int, defenders_defeated: int):
	$AnimationPlayer.play("SIze")
	assert($AnimationPlayer.connect("animation_finished", self, "remove") == OK)

	$Viewport/HBoxContainer/Attacker.set_text(str(attacker_defeated))
	$Viewport/HBoxContainer/Defender.set_text(str(defenders_defeated))

	# Czarny ekran przy get_data z tekstury
	var img = $Viewport.get_texture()
	$Numbers.set_texture(img)


func remove(_unused) -> void:
	queue_free()
