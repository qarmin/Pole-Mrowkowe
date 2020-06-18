extends Camera

const LOOKAROUND_SPEED : float = 0.0025
const MOVE_CAMERA : float = 0.0025
const MOVE_SPEED : float = 1.0
const MOVING_BOX : PoolVector3Array = PoolVector3Array([Vector3(0.0,0.0,0.0), Vector3(20.0,20.0,20.0)])# Wymiary paczki ograniczające gracza

# Używane w obracaniu obrazem
onready var rot_x : float = 0.0
onready var rot_y : float = 0.0

var projection_changed : bool = false 

enum CAMERA_MOVEMENT {BACK_SCROLL,FORWARD_SCROLL,LEFT,RIGHT,UP,DOWN}



func _ready() -> void:
	# Ustawia zmienne na pozycje ustawione w edytorze(nic nie zmienia)
	rot_x = get_rotation().y
	rot_y = get_rotation().x

func _input(event) -> void:
	# Klawiatura
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_R: # Reset Kamery
				#
				pass
			if event.get_scancode() == KEY_DOWN: # Zmiana projekcji
				if !projection_changed:
					if get_projection() == Camera.PROJECTION_PERSPECTIVE:
						set_projection(Camera.PROJECTION_ORTHOGONAL)
					else:
						set_projection(Camera.PROJECTION_PERSPECTIVE)
					projection_changed = true
			if event.get_scancode():
				pass
		else:
			if event.get_scancode() == KEY_DOWN:
				projection_changed = false
	
	# Mysz - kliknięcie
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_mask() == BUTTON_MASK_MIDDLE: # Środokowy przycisk myszy - Klik
				pass
			if event.get_button_mask() & 8: # Scroll w górę
				move_camera(CAMERA_MOVEMENT.FORWARD_SCROLL)
				pass
			if event.get_button_mask() & 16: # Scroll w dół
				move_camera(CAMERA_MOVEMENT.BACK_SCROLL)
				pass
	
	# Mysz - poruszanie
	if event is InputEventMouseMotion:
		if event.get_button_mask() == BUTTON_LEFT: # Lewy przycisk myszy
			pass
		if event.get_button_mask() == BUTTON_RIGHT: # Prawy przycisk myszy - na chwilę obraca kamerą wokół własnej osi Y
			rot_x -= event.relative.x * LOOKAROUND_SPEED
			rot_y -= event.relative.y * LOOKAROUND_SPEED
			
			#rot_x = clamp(rot_x,-0.6,-0.3)
			rot_y = clamp(rot_y,-0.9,-0.5)
			
			transform.basis = Basis()
			rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X



func move_camera(roman : int) -> void:
	var move_vec : Vector3 = Vector3()
	match(roman):
		CAMERA_MOVEMENT.BACK_SCROLL:
			move_vec.z += 1
		CAMERA_MOVEMENT.FORWARD_SCROLL:
			move_vec.z -= 1
		CAMERA_MOVEMENT.UP:
			move_vec.z -= 1
		CAMERA_MOVEMENT.DOWN:
			move_vec.z += 1
		CAMERA_MOVEMENT.LEFT:
			move_vec.x -= 1
		CAMERA_MOVEMENT.RIGHT:
			move_vec.x += 1
		_:
			printerr("Nie nadano poprawnej wartości dla move_camera")
			pass
	#move_vec = move_vec.rotated(Vector3(0,1,0),rotation_degrees.y)
	translate(move_vec * MOVE_SPEED)
	# TODO # Clamp pozycje gracza aby nie wychodził poza obszar
	#global_translate(move_vec * MOVE_SPEED)
#
#func _ready() -> void:
#	pass
#
#	trans_speed = TRANSLATE_SPEED  * delta
#	if Input.is_action_pressed("ui_camera_up"):
#		translate(Vector3(0,0,-trans_speed))
