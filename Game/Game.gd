extends Spatial


func _ready() -> void:
	connect_signals()
	pass


func connect_signals() -> void:
	# Łączenie każdego pola oraz mrówki na mapie z funkcją wyświelającą 
	for single_hex in $Map.get_children():
		assert(single_hex.get_name().begins_with("SingleHex"))
		assert(single_hex.connect("hex_clicked", self, "hex_clicked") == OK)
		for thing in single_hex.get_children():
			if ! thing.get_name().begins_with("Ant"):
				continue
			print(thing)
			assert(thing.connect("ant_clicked", self, "ant_clicked") == OK)


func ant_clicked(ant: AntBase) -> void:
	print("Ant " + ant.get_name() + " was clicked and this was handled!")


func hex_clicked(hex: SingleHex) -> void:
	print("Hex " + hex.get_name() + " was clicked and this was handled!")
