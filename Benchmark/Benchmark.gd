extends Spatial

var current_stage : int = 1
var test_speed : float = 10.0

var ready : bool = false
var start_wait_time : float = 1.0
var middle_wait_time : float = 1.0
var benchmark_ended : bool = false
var benchmark_started : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_ESCAPE:
				ready = false
				Benchmark.clear_results()
				test_ended()

func _ready(): 
	$Settings.set_text("Configuring environment")
		
	Benchmark.clear_results()
	
func test_started() -> void:
	benchmark_started = true
	
	Options.benchmark_save_current_settings_state()
	Options.load_min_settings()
	$WorldEnvironment.set_environment(null)
	
	$CameraMovement.play("CameraMovement1")
	$CameraMovement.set_speed_scale(test_speed)
	$Settings.set_text("Minimal Settings(1/6)\nMap 3x3")
	
	ready = true

func test_middle() -> void:
	benchmark_started = true
	
	Options.load_max_settings()
	
	current_stage = 4
	$Map3.hide()
	$Map.show()
	$CameraMovement.play("CameraMovement4")
	$CameraMovement.set_speed_scale(test_speed)
	$Settings.set_text("Maximum Settings(4/6)\nMap 3x3")
	
	ready = true
	
func test_ended() -> void:
	benchmark_ended = true
	
	Options.benchmark_load_saved_settings_state()
	
	for i in range(6):
		Benchmark.stages[i] = int(Benchmark.stages[i] * test_speed)
	Benchmark.points = int(Benchmark.points * test_speed)
	
	
	print("Wynik ogólny - " + str(Benchmark.points))
	print("Minimalne Ustawienia")
	print("Etap 1 - " + str(Benchmark.stages[0]))
	print("Etap 2 - " + str(Benchmark.stages[1]))
	print("Etap 3 - " + str(Benchmark.stages[2]))
	print("Maksymalne Ustawienia")
	print("Etap 4 - " + str(Benchmark.stages[3]))
	print("Etap 5 - " + str(Benchmark.stages[4]))
	print("Etap 6 - " + str(Benchmark.stages[5]))
	
	Benchmark.benchmarks_waits_to_be_shown = true
	
	if get_tree().change_scene("res://Menu/MenuCommon/MenuCommon.tscn") != OK:
		assert(false)
	
func _process(delta: float) -> void:
	if !benchmark_ended:
		if ready:
			Benchmark.stages[current_stage-1] += 1
			Benchmark.points += 1
		elif !ready:
			if start_wait_time >= 0:
				start_wait_time -= delta
				if start_wait_time < 0:
					test_started()
			elif middle_wait_time >= 0:
				middle_wait_time -= delta
				if middle_wait_time < 0:
					test_middle()
		

func _animation_finished(anim_name: String) -> void:
	if anim_name == "CameraMovement1":
		current_stage = 2
		$Map.hide()
		$Map2.show()
		$CameraMovement.play("CameraMovement2")
		$CameraMovement.set_speed_scale(test_speed)
		$Settings.set_text("Minimal Settings(2/6)\nMap 10x10")
	elif(anim_name == "CameraMovement2"):
		current_stage = 3
		$Map2.hide()
		$Map3.show()
		$CameraMovement.play("CameraMovement3")
		$CameraMovement.set_speed_scale(test_speed)
		$Settings.set_text("Minimal Settings(3/6)\nMap 30x30")
	elif anim_name == "CameraMovement3":
		$WorldEnvironment.set_environment(load("res://default_env.tres"))
		ready = false
	elif anim_name == "CameraMovement4":
		current_stage = 5
		$Map.hide()
		$Map2.show()
		$CameraMovement.play("CameraMovement5")
		$CameraMovement.set_speed_scale(test_speed)
		$Settings.set_text("Maximum Settings(5/6)\nMap 10x10")
	elif anim_name == "CameraMovement5":
		current_stage = 6
		$Map2.hide()
		$Map3.show()
		$CameraMovement.play("CameraMovement6")
		$CameraMovement.set_speed_scale(test_speed)
		$Settings.set_text("Maximum Settings(6/6)\nMap 30x30(6/6)")
	elif anim_name == "CameraMovement6":
		test_ended()
