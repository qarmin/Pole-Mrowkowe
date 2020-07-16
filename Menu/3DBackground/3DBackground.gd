extends Spatial


func _ready():
	$AnimationPlayerCamera.play("BasicCameraMovement")
	$AnimationPlayerLight.play("LightMovement")
