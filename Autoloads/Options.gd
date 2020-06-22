extends Node

# Todo - zapisywanie ustawień do pliku jeśli nie jest to akurat zapisywanie ustawień przez benchmark

var msaa : int = 0
var default_environment : String = ""





func _ready() -> void:
	pass


func benchmark_save_current_settings_state():
	msaa = ProjectSettings.get_setting("rendering/quality/filters/msaa")
	default_environment = ProjectSettings.get_setting("rendering/environment/default_environment")
	

func benchmark_load_saved_settings_state():
	ProjectSettings.set_setting("rendering/quality/filters/msaa", msaa)
