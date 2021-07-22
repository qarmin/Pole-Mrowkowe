extends Node3D


func _ready():
	$AnimationPlayerCamera.play("BasicCameraMovement")
	$AnimationPlayerLight.play("LightMovement")
