extends Node

var file_name : String = "save_file"
var file_name_extension : String = ".sav"
var file_handler : File = File.new()
var create_file_backup : bool = false #Tworzy kopie savefile.sav savefile.backup.sav savefile.backup2.sav

func _ready() -> void:
	pass
	
func save_game() -> void:
	if create_file_backup:
		pass
	else:
		pass
	pass
	
func load_game() -> void:
	pass