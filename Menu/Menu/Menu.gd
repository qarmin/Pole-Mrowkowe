extends Control


func _ready() -> void:
	$"3DBackground".show()
	if Benchmark.benchmarks_waits_to_be_shown:
		hide_all_except($MenuBenchmark)
		$MenuBenchmark.show_benchmarks()
		Benchmark.benchmarks_waits_to_be_shown = false
	else:
		_back_to_menu()


func _exit_game() -> void:
	get_tree().quit()


func hide_all_except(choosen_node: Node):
	if choosen_node == $MainMenu:
		$MainMenu.show()
	else:
		$MainMenu.hide()

	if choosen_node == $MenuBenchmark:
		$MenuBenchmark.show()
	else:
		$MenuBenchmark.hide()

	if choosen_node == $MenuOptions:
		$MenuOptions.show()
	else:
		$MenuOptions.hide()

	if choosen_node == $MenuSkirmishNewGame:
		$MenuSkirmishNewGame.show()
	else:
		$MenuSkirmishNewGame.hide()

	if choosen_node == $MenuCampaign:
		$MenuCampaign.show()
	else:
		$MenuCampaign.hide()

	if choosen_node == $MenuCampaignLoad:
		$MenuCampaignLoad.show()
	else:
		$MenuCampaignLoad.hide()

	if choosen_node == $MenuCampaignNew:
		$MenuCampaignNew.show()
	else:
		$MenuCampaignNew.hide()


func _back_to_menu() -> void:
	hide_all_except($MainMenu)
	

func _skirmish_menu_show() -> void:
	hide_all_except($MenuSkirmishNewGame)


func _options_menu_show() -> void:
	hide_all_except($MenuOptions)


func _benchmark_menu_show() -> void:
	hide_all_except($MenuBenchmark)


func _campaign_menu_show() -> void:
	hide_all_except($MenuCampaign)
