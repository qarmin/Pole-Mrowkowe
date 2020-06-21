extends Spatial

var current_stage : int = 1

func _ready(): 
	Benchmark.points = 0
	for i in range (3):
		Benchmark.stages[i] = 0
	
	$CameraMovement.play("CameraMovement1")
	pass
func _process(_delta: float) -> void:
	Benchmark.stages[current_stage-1] += 1
	Benchmark.points += 1


func _animation_finished(anim_name: String) -> void:
	print("Zakończyłem")
	if(anim_name == "CameraMovement1"):
		current_stage = 2
		$Map.hide()
		$Map2.show()
		$CameraMovement.play("CameraMovement2")
	elif(anim_name == "CameraMovement2"):
		current_stage = 3
		$Map2.hide()
		$Map3.show()
		$CameraMovement.play("CameraMovement3")
	elif anim_name == "CameraMovement3":
		print("Wynik ogólny - " + str(Benchmark.points))
		print("Etap 1 - " + str(Benchmark.stages[0]))
		print("Etap 2 - " + str(Benchmark.stages[1]))
		print("Etap 3 - " + str(Benchmark.stages[2]))
		

	pass # Replace with function body.
