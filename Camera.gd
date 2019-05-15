extends Camera

const LOOKAROUND_SPEED : float = 0.005
const MOVING_BOX : PoolVector3Array = PoolVector3Array([Vector3(0.0,0.0,0.0), Vector3(20.0,20.0,20.0)])# Wymiary paczki ograniczające gracza
# accumulators
onready var rot_x : float = 0.0
onready var rot_y : float = 0.0

func _ready() -> void:
	transform.basis = Basis() # reset rotation
	rotate_object_local(Vector3(0, 1, 0), rot_x)
	rotate_object_local(Vector3(1, 0, 0), rot_y)
#	rot_x = transform.basis.x.x
#	rot_y = transform.basis.y.y

func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 2:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
#
#func _ready() -> void:
#	pass
#
#func _process(delta : float) -> void:
#	trans_speed = TRANSLATE_SPEED  * delta
#	if Input.is_action_pressed("ui_camera_up"):
#		translate(Vector3(0,0,-trans_speed))
		