extends CSGTorus

var speed: float = 1.2
var rotation_speed: float = 1
var basic_transform: Vector3 = Vector3()
var direction: float = 1.0
var min_max_y: Vector2 = Vector2(-0.3, 0.2)


func _ready() -> void:
	reset()
	stop()
	
func reset() -> void:
	basic_transform = get_translation()
	translate(Vector3(0, min_max_y.x, 0))

func start() -> void:
	show()
	set_process(true)
	
func stop() -> void:
	hide()
	set_process(false)

func _process(delta: float) -> void:
	rotate(Vector3(0, 1, 0).normalized(), rotation_speed * delta)
	if get_translation().y > basic_transform.y + min_max_y.y:
		direction = -1.0
	elif get_translation().y < basic_transform.y + min_max_y.x:
		direction = 1.0
		
	translate(Vector3(0, direction * speed * delta, 0))
