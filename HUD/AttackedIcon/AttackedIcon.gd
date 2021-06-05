extends Sprite3D


func show_icon(attacker_units: int, defenders_units: int, attacker_defeated: int, defenders_defeated: int):
	$AnimationPlayer.play("SIze")
	assert($AnimationPlayer.connect("animation_finished", self, "remove") == OK)

	$Viewport/Fight/Basic/Attacker.set_text(str(attacker_units))
	$Viewport/Fight/Basic/Defender.set_text(str(defenders_units))
	$Viewport/Fight/Lost/Attacker.set_text(str(attacker_defeated))
	$Viewport/Fight/Lost/Defender.set_text(str(defenders_defeated))

	# Czarny ekran przy get_data z tekstury
	var img = $Viewport.get_texture()
	$Numbers.set_texture(img)


func remove(_unused) -> void:
	queue_free()
