extends Spatial

var current_stage: int = 1

var ready: bool = false
var start_wait_time: float = 1.0
var middle_wait_time: float = 1.0
var benchmark_ended: bool = false
var benchmark_started: bool = false


## Umożliwia przerwanie testu za pomocą przyisku ESCAPE
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_ESCAPE:
				ready = false
				Benchmark.clear_results()
				test_ended()


## Przy wejściu czyści wyniki
func _ready():
	$Settings.set_text("Configuring environment")

	Benchmark.clear_results()


## Wyświetla określoną mapę i chowa inne
func show_map(map_number: int) -> void:
	var map_array: Array = [false, false, false]
	assert(map_number >= 1 && map_number <= map_array.size())
	map_array[map_number - 1] = true

	for i in range(map_array.size()):
		if map_array[i] == true:
			get_node("Map" + str(i + 1)).show()
		else:
			get_node("Map" + str(i + 1)).hide()


## Ładuje mapy z niskimi ustawieniami
func test_started() -> void:
	benchmark_started = true

	Options.benchmark_load_min_settings()
	$WorldEnvironment.set_environment(null)
	#$DirectionalLight.set_param(Light.PARAM_ENERGY,0.8)
	#$DirectionalLight.set_shadow(false) # Patrz niżej
	$Water.hide()

	current_stage = 1
	show_map(1)
	$CameraMovement.play("CameraMovement1")
	$CameraMovement.set_speed_scale(Benchmark.speed_scale)
	$Settings.set_text("Minimal Settings(1/6)\nMap 3x3")

	ready = true


## Ładuje mapy z wysokimi ustawieniami
func test_middle() -> void:
	benchmark_started = true

	Options.benchmark_load_max_settings()
	$WorldEnvironment.set_environment(load("res://standard_environment.tres"))
	$Water.show()

	current_stage = 4
	show_map(1)
	$CameraMovement.play("CameraMovement4")
	$CameraMovement.set_speed_scale(Benchmark.speed_scale)
	$Settings.set_text("Maximum Settings(4/6)\nMap 3x3")

	ready = true


## Na zakończenie wypisuje wyniki i ładuje scene z benchmarkiem
func test_ended() -> void:
	benchmark_ended = true

	Benchmark.normalize_results()

	### Print Values
	print("Wynik ogólny - " + str(Benchmark.points))
	print("Minimalne Ustawienia")
	print("Etap 1 - " + str(Benchmark.stages_frames[0]))
	print("Etap 2 - " + str(Benchmark.stages_frames[1]))
	print("Etap 3 - " + str(Benchmark.stages_frames[2]))
	print("Maksymalne Ustawienia")
	print("Etap 4 - " + str(Benchmark.stages_frames[3]))
	print("Etap 5 - " + str(Benchmark.stages_frames[4]))
	print("Etap 6 - " + str(Benchmark.stages_frames[5]))

	## Ustawia zmienną, która spowoduje że przejście do Menu Głównego od razu przeniesie do benchmarku
	Benchmark.benchmarks_waits_to_be_shown = true

	if get_tree().change_scene("res://Menu/Menu/Menu.tscn") != OK:
		assert(false)


## Dodaje co każdą klatkę do wyniku 1 punkt i sprawdza czy dany test się nie zakończył
func _process(delta: float) -> void:
	if !benchmark_ended:
		if ready:
			Benchmark.stages_frames[current_stage - 1] += 1
			Benchmark.points += 1
			Benchmark.time_frame[current_stage - 1].append(delta)
		else:
			if start_wait_time >= 0:
				start_wait_time -= delta
				if start_wait_time < 0:
					test_started()
			elif middle_wait_time >= 0:
				middle_wait_time -= delta
				if middle_wait_time < 0:
					test_middle()


## Ładuje poszczególne etapy
func _animation_finished(anim_name: String) -> void:
	if anim_name == "CameraMovement1":
		current_stage = 2
		show_map(2)
		$CameraMovement.play("CameraMovement2")
		$CameraMovement.set_speed_scale(Benchmark.speed_scale)
		$Settings.set_text("Minimal Settings(2/6)\nMap 10x10")
	elif anim_name == "CameraMovement2":
		current_stage = 3
		show_map(3)
		$CameraMovement.play("CameraMovement3")
		$CameraMovement.set_speed_scale(Benchmark.speed_scale)
		$Settings.set_text("Minimal Settings(3/6)\nMap 30x30")
	elif anim_name == "CameraMovement3":
		$Settings.set_text("Configuring environment")
		#$DirectionalLight.set_param(Light.PARAM_ENERGY,0.0)
		#$DirectionalLight.set_shadow(true) # TODO - Zrobić aby cienie były tylko w GLES 3 lub Vulkanie - GLES 2 ma bardzo kanciaste cienie
		ready = false
	elif anim_name == "CameraMovement4":
		current_stage = 5
		show_map(2)
		$CameraMovement.play("CameraMovement5")
		$CameraMovement.set_speed_scale(Benchmark.speed_scale)
		$Settings.set_text("Maximum Settings(5/6)\nMap 10x10")
	elif anim_name == "CameraMovement5":
		current_stage = 6
		show_map(3)
		$CameraMovement.play("CameraMovement6")
		$CameraMovement.set_speed_scale(Benchmark.speed_scale)
		$Settings.set_text("Maximum Settings(6/6)\nMap 30x30(6/6)")
	elif anim_name == "CameraMovement6":
		test_ended()
