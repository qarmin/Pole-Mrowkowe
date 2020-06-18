extends Camera

const LOOKAROUND_SPEED : float = 0.0025
const MOVE_CAMERA : float = 0.0025
const MOVING_BOX : PoolVector3Array = PoolVector3Array([Vector3(0.0,0.0,0.0), Vector3(20.0,20.0,20.0)])# Wymiary paczki ograniczające gracza
# accumulators
onready var rot_x : float = 0.0
onready var rot_y : float = 0.0

var camera_key_changed : bool = false 

func _ready() -> void:
	# Ustawia zmienne na pozycje ustawione w edytorze(nic nie zmienia)
	rot_x = get_rotation().y
	rot_y = get_rotation().x

func _input(event):
	# Klawiatura
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_DOWN:
				if !camera_key_changed:
					if get_projection() == Camera.PROJECTION_PERSPECTIVE:
						set_projection(Camera.PROJECTION_ORTHOGONAL)
					else:
						set_projection(Camera.PROJECTION_PERSPECTIVE)
					camera_key_changed = true
		else:
			if event.get_scancode() == KEY_DOWN:
				camera_key_changed = false
	
	# Mysz - kliknięcie
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_mask() == BUTTON_MASK_MIDDLE: # Środokowy przycisk myszy - Klik
				print("ŚR")
				pass
			if event.get_button_mask() == 8:
				print("8")
				pass
			if event.get_button_mask() == 16:
				print("16")
				pass
	
	# Mysz - poruszanie
	if event is InputEventMouseMotion:
		if event.get_button_mask() == BUTTON_LEFT: # Lewy przycisk myszy
			pass
		if event.get_button_mask() == BUTTON_RIGHT: # Prawy przycisk myszy
			rot_x -= event.relative.x * LOOKAROUND_SPEED
			rot_y -= event.relative.y * LOOKAROUND_SPEED
			
			#rot_x = clamp(rot_x,-0.6,-0.3)
			rot_y = clamp(rot_y,-0.9,-0.5)
			
			transform.basis = Basis()
			rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
#
#func _ready() -> void:
#	pass
#
#	trans_speed = TRANSLATE_SPEED  * delta
#	if Input.is_action_pressed("ui_camera_up"):
#		translate(Vector3(0,0,-trans_speed))
