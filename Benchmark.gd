extends Spatial

var current_stage : int = 1
var settings : String = "Min"
var test_speed : float = 30.0

var wait_time : float = 0.5
var benchmark_ended : bool = false
var benchmark_started : bool = false

func _ready(): 
	$Settings.set_text("Configuring environment")
		
	Benchmark.points = 0
	for i in range (3):
		Benchmark.stages[i] = 0
	
func test_started() -> void:
	benchmark_started = true
	
	$CameraMovement.play("CameraMovement1")
	$CameraMovement.set_speed_scale(test_speed)
	$Settings.set_text("Minimal Settings\nMap 3x3")
	

func test_ended() -> void:
	benchmark_ended = true
	
	print("Wynik ogólny - " + str(Benchmark.points))
	print("Minimalne Ustawienia")
	print("Etap 1 - " + str(Benchmark.stages[0]))
	print("Etap 2 - " + str(Benchmark.stages[1]))
	print("Etap 3 - " + str(Benchmark.stages[2]))
	print("Maksymalne Ustawienia")
	print("Etap 4 - " + str(Benchmark.stages[3]))
	print("Etap 5 - " + str(Benchmark.stages[4]))
	print("Etap 6 - " + str(Benchmark.stages[5]))
	
func _process(delta: float) -> void:
	if benchmark_started && !benchmark_ended:
		Benchmark.stages[current_stage-1] += 1
		Benchmark.points += 1
	elif !benchmark_started:
		wait_time -= delta
		if wait_time < 0:
			test_started()

func _animation_finished(anim_name: String) -> void:
	print("Zakończyłem")
	if anim_name == "CameraMovement1":
		if settings == "Min":
			current_stage = 2
			$Map.hide()
			$Map2.show()
			$CameraMovement.play("CameraMovement2")
			$CameraMovement.set_speed_scale(test_speed)
			$Settings.set_text("Minimal Settings\nMap 10x10")
		else:
			current_stage = 5
			$Map.hide()
			$Map2.show()
			$CameraMovement.play("CameraMovement2")
			$CameraMovement.set_speed_scale(test_speed)
			$Settings.set_text("Maximum Settings\nMap 10x10")
	elif(anim_name == "CameraMovement2"):
		if settings == "Min":
			current_stage = 3
			$Map2.hide()
			$Map3.show()
			$CameraMovement.play("CameraMovement3")
			$CameraMovement.set_speed_scale(test_speed)
			$Settings.set_text("Minimal Settings\nMap 30x30")
		else:
			current_stage = 6
			$Map2.hide()
			$Map3.show()
			$CameraMovement.play("CameraMovement3")
			$CameraMovement.set_speed_scale(test_speed)
			$Settings.set_text("Maximum Settings\nMap 30x30")
	elif anim_name == "CameraMovement3":
		if settings == "Min":
			current_stage = 4
			$Map3.hide()
			$Map.show()
			$CameraMovement.play("CameraMovement1")
			$CameraMovement.set_speed_scale(test_speed)
			$Settings.set_text("Maximum Settings\nMap 3x3")
			
			settings = "Max"
		else:
			test_ended()
		

	pass # Replace with function body.
