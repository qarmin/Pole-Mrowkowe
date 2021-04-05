extends Camera

# Prędkość rozglądania się za pomocą kursora myszy
const LOOKAROUND_SPEED: float = 0.0025

# Prędkość skrolowania na myszy
const SCROLL_SPEED: float = 1.0

# Prędkość poruszania się za pomocą strzałek
const MOVEMENT_SPEED: float = 10.0

# Wymiary paczki ograniczające gracza
const MOVING_BOX: PoolVector3Array = PoolVector3Array([Vector3(0.0, 0.0, 0.0), Vector3(20.0, 20.0, 20.0)])

# Używane w obracaniu obrazem
onready var rot_x: float = 0.0
onready var rot_y: float = 0.0

var projection_changed: bool = false

enum CAMERA_MOVEMENT { BACK_SCROLL = 1 << 0, FORWARD_SCROLL = 1 << 1, LEFT = 1 << 2, RIGHT = 1 << 3, UP = 1 << 4, DOWN = 1 << 5, FASTER }

var movement_keys_pressed: int = 0

var camera_min_position: Vector3 = Vector3(-10, 3, -10)
var camera_max_position: Vector3 = Vector3(10, 10, 10)


func _ready() -> void:
	# Ustawia zmienne na pozycję kamery na tą ustawioną w edytorze
	rot_x = get_rotation().y
	rot_y = get_rotation().x


func _input(event) -> void:
	# Klawiatura
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_R:  # Reset Kamery
				set_translation(Vector3(-0.443, 7.127, 5.624))
				look_at(Vector3(0, 0, 0), Vector3(0, 1, 0))
				rot_x = get_rotation().y
				rot_y = get_rotation().x
			if event.get_scancode() == KEY_P:  # Zmiana projekcji
				if !projection_changed:
					if get_projection() == Camera.PROJECTION_PERSPECTIVE:
						set_projection(Camera.PROJECTION_ORTHOGONAL)
					else:
						set_projection(Camera.PROJECTION_PERSPECTIVE)
					projection_changed = true
			if event.get_scancode() == KEY_UP || event.get_scancode() == KEY_W:
				movement_keys_pressed |= CAMERA_MOVEMENT.UP
			elif event.get_scancode() == KEY_DOWN || event.get_scancode() == KEY_S:
				movement_keys_pressed |= CAMERA_MOVEMENT.DOWN
			if event.get_scancode() == KEY_LEFT || event.get_scancode() == KEY_A:
				movement_keys_pressed |= CAMERA_MOVEMENT.LEFT
			elif event.get_scancode() == KEY_RIGHT || event.get_scancode() == KEY_D:
				movement_keys_pressed |= CAMERA_MOVEMENT.RIGHT

		else:
			if event.get_scancode() == KEY_P:
				projection_changed = false
			if event.get_scancode() == KEY_UP || event.get_scancode() == KEY_W:
				movement_keys_pressed &= ~CAMERA_MOVEMENT.UP
			if event.get_scancode() == KEY_DOWN || event.get_scancode() == KEY_S:
				movement_keys_pressed &= ~CAMERA_MOVEMENT.DOWN
			if event.get_scancode() == KEY_LEFT || event.get_scancode() == KEY_A:
				movement_keys_pressed &= ~CAMERA_MOVEMENT.LEFT
			if event.get_scancode() == KEY_RIGHT || event.get_scancode() == KEY_D:
				movement_keys_pressed &= ~CAMERA_MOVEMENT.RIGHT

	# Mysz - kliknięcie
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_mask() == BUTTON_MASK_MIDDLE:  # Środokowy przycisk myszy - Klik
				pass
			if event.get_button_mask() == 8:  # Scroll w górę
				if get_projection() == Camera.PROJECTION_PERSPECTIVE:
					move_camera(CAMERA_MOVEMENT.FORWARD_SCROLL)
				pass
			if event.get_button_mask() == 16:  # Scroll w dół
				if get_projection() == Camera.PROJECTION_PERSPECTIVE:
					move_camera(CAMERA_MOVEMENT.BACK_SCROLL)
				pass

	# Mysz - poruszanie
	if event is InputEventMouseMotion:
		if event.get_button_mask() == BUTTON_LEFT:  # Lewy przycisk myszy
			pass
		if event.get_button_mask() == BUTTON_RIGHT:  # Prawy przycisk myszy - na chwilę obraca kamerą wokół własnej osi Y
			rot_x -= event.relative.x * LOOKAROUND_SPEED
			rot_y -= event.relative.y * LOOKAROUND_SPEED

			#rot_x = clamp(rot_x,-0.6,-0.3)
			rot_y = clamp(rot_y, -0.9, -0.5)

			transform.basis = Basis()
			rotate_object_local(Vector3(0, 1, 0), rot_x)  # first rotate in Y
			rotate_object_local(Vector3(1, 0, 0), rot_y)  # then rotate in X


func move_camera(roman: int, delta: float = -1) -> void:
	if delta < 0:
		delta = 1.0

	var move_vec_local: Vector3 = Vector3()
	var move_vec_global: Vector3 = Vector3()

	if roman & CAMERA_MOVEMENT.BACK_SCROLL == CAMERA_MOVEMENT.BACK_SCROLL:
		move_vec_local.z += SCROLL_SPEED
	elif roman & CAMERA_MOVEMENT.FORWARD_SCROLL == CAMERA_MOVEMENT.FORWARD_SCROLL:
		move_vec_local.z -= SCROLL_SPEED
	if roman & CAMERA_MOVEMENT.UP == CAMERA_MOVEMENT.UP:
		move_vec_global.x -= sin(get_rotation().y) * MOVEMENT_SPEED
		move_vec_global.z -= cos(get_rotation().y) * MOVEMENT_SPEED
	elif roman & CAMERA_MOVEMENT.DOWN == CAMERA_MOVEMENT.DOWN:
		move_vec_global.x += sin(get_rotation().y) * MOVEMENT_SPEED
		move_vec_global.z += cos(get_rotation().y) * MOVEMENT_SPEED
	if roman & CAMERA_MOVEMENT.LEFT == CAMERA_MOVEMENT.LEFT:
		move_vec_local.x -= MOVEMENT_SPEED
	elif roman & CAMERA_MOVEMENT.RIGHT == CAMERA_MOVEMENT.RIGHT:
		move_vec_local.x += MOVEMENT_SPEED
	#move_vec = move_vec.rotated(Vector3(0,1,0),rotation_degrees.y)

	if move_vec_local != Vector3():
		# Jeśli jest ruch, to najpierw testujemy czy przypadkiem nie wyjdzie poza dopuszczalny obszar
		# Jeśli nie wyjdzie to pozwalamy mu się poruszać z pełną prędkością po mapie,
		# Jeśli wyjdzie to wtedy skalujemy ruch, tak aby oś y zatrzymała się równo na granicy

		var current_transform: Transform = get_transform()
		translate(move_vec_local * delta)
		# Skala jaką należy zaaplikować do prędkości aby nie wypaść poza obręb mapy
		var move_scale: float = 1
#		var move_scale : Vector3 = Vector3(1,1,1)

		if get_global_transform().origin.y > camera_max_position.y:
			move_scale = 0.0
		elif get_global_transform().origin.y < camera_min_position.y:
			move_scale = 0.0
		if get_global_transform().origin.z > camera_max_position.z:
			move_scale = 0.0
		elif get_global_transform().origin.z < camera_min_position.z:
			move_scale = 0.0
		if get_global_transform().origin.x > camera_max_position.x:
			move_scale = 0.0
		elif get_global_transform().origin.x < camera_min_position.x:
			move_scale = 0.0

		transform = current_transform

		translate(move_vec_local * delta * move_scale)

	if move_vec_global != Vector3():
		global_translate(move_vec_global * delta)
		translation.z = clamp(translation.z, camera_min_position.z, camera_max_position.z)
		translation.x = clamp(translation.x, camera_min_position.x, camera_max_position.x)
		pass


func _process(delta: float) -> void:
	if movement_keys_pressed != 0:
		move_camera(movement_keys_pressed, delta)

#func _ready() -> void:
#	pass
#
#	trans_speed = TRANSLATE_SPEED  * delta
#	if Input.is_action_pressed("ui_camera_up"):
#		translate(Vector3(0,0,-trans_speed))
