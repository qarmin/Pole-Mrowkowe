extends Spatial

var cpu_vs_cpu: bool = false  # Allow to have fully automated game

enum PLAYERS_TYPE {NO_TYPE, HUMAN, CPU}

# TODO to ma być ustawiane 

var number_of_start_players: int = 4  # Number of all players
var active_players: int = 3  # How many players still play
var current_player: int = 0  # Actual player
var players_activite: Array = [true, true, false, true]  # Stan aktualny w graczach, czy ciągle żyją
var players_type: Array = [PLAYERS_TYPE.HUMAN, PLAYERS_TYPE.HUMAN, PLAYERS_TYPE.CPU, PLAYERS_TYPE.CPU]
# TODO Maybe players name?
var player_resources : Array = []

onready var round_node = $HUD/HUD/Round
onready var round_label = $HUD/HUD/Round/Label
onready var confirmation_dialog = $HUD/HUD/ConfirmationDialog

# Selection
var current_terrain_overlay_hex_name: String = ""
var current_unit_overlay_hex_name: String = ""

var selected_ant: Node = null
var selected_hex: Node = null

var selection_ant_color_own: Color = Color("#6689d400")
var selection_ant_color_enemy: Color = Color("#2cd91515")

var selection_hex_color_own: Color = Color("#6689d400")
var selection_hex_color_enemy: Color = Color("#2cd91515")

var terrain_overlay_node: CSGTorus = preload("res://Overlay/TerrainOverlay.tscn").instance()
var unit_overlay_node: CSGTorus = preload("res://Overlay/UnitOverlay.tscn").instance()

onready var single_map: SingleMap = SingleMap.new()


func _ready() -> void:
	# TODO, generacja nie powinna tu być, lecz zależeć od wcześniejszych wyborów gracza
	MapCreator.create_map(single_map, Vector2j.new(6, 6), 80)
	assert(MapCreator.populate_map_randomly(single_map, 50))
	MapCreator.create_3d_map(single_map)
	add_child(single_map.map)
	
	# Ustawianie tutaj wielkości dozwolonego przez kamerę obszaru
	$Camera.set_camera_max_positions(single_map.size)
		
	# Aktualizacja koloru gracz na mapie
	$HUD/HUD.update_current_player_text_color(current_player)
		
	# Start Resources
	player_resources.resize(number_of_start_players)
	for i in range(number_of_start_players):
		player_resources[i] = {"wood": (i+2)* 100, "water" : (i+2)* 100, "gold" : (i+2)*100, "food" : (i+2)*100}
	
	# Water
	var water : Spatial = load("res://Terrain/Water/Water.tscn").instance()
	water.set_scale(Vector3(1000,1,1000))
	add_child(water)
	

	$Overlays.add_child(terrain_overlay_node)
	$Overlays.add_child(unit_overlay_node)
	for i in $Overlays.get_children():
		i.hide()

	connect_clickable_signals()
	pass

func _process(_delta : float) -> void:
	# TODO Add logic to CPU movement
	pass

func connect_clickable_signals() -> void:
	# Łączenie każdego pola oraz mrówki na mapie z funkcją wyświelającą
	for single_hex in $Map.get_children():
		assert(single_hex.get_name().begins_with("SingleHex"))
		assert(single_hex.connect("hex_clicked", self, "hex_clicked") == OK)
		for thing in single_hex.get_children():
			if thing.get_name() != "Ant":
				continue
			assert(thing.connect("ant_clicked", self, "ant_clicked") == OK)
	
	
	# TODO Po zakończeniu testów, zacząć pokazywać okno potwierdzające chęć zakończenia tury
#	round_node.connect("try_to_end_turn_clicked",self,"try_to_end_turn")
	round_node.connect("end_turn",self,"try_to_end_turn")
	
	confirmation_dialog.connect("confirmed", self, "end_turn")
	

func ant_clicked(ant: AntBase) -> void:
	var parent_name: String = ant.get_parent().get_name()
#	print("Ant " + parent_name + "/" + ant.get_name() + " was clicked and this was handled!")

	# Jeśli mrówka była wcześniej kliknięta, to usuwamy zaznaczenie
	if parent_name == current_unit_overlay_hex_name:
		unit_overlay_node.stop()
		current_unit_overlay_hex_name = ""
		selected_ant = null
		hide_menus()
		return

	# Na wszelki wypadek odznaczamy zaznaczenie na terenie
	terrain_overlay_node.stop()
	current_terrain_overlay_hex_name = ""
	selected_hex = null

	# Sprawdzenie czy aktualny gracz klika na wroga czy na siebie i dopasowuje do tego kolor
	if single_map.get_field_owner(SingleMap.convert_name_to_coordinates(parent_name, single_map.size)) == current_player:
		unit_overlay_node.get_material().albedo_color = selection_ant_color_own
	else:
		unit_overlay_node.get_material().albedo_color = selection_ant_color_enemy

	unit_overlay_node.set_translation(ant.get_translation() + ant.get_parent().get_translation())
	unit_overlay_node.set_scale(ant.get_scale())
	unit_overlay_node.reset()
	unit_overlay_node.start()
	current_unit_overlay_hex_name = parent_name
	selected_ant = ant
	show_units_menu()
	$HUD/HUD/Units/VBox/Label.set_text("unit menu - field ")


func hex_clicked(hex: SingleHex) -> void:
	# TODO checkif players
#	print("Hex " + hex.get_name() + " was clicked and this was handled!")
	if hex.get_name() == current_terrain_overlay_hex_name:
		terrain_overlay_node.stop()
		current_terrain_overlay_hex_name = ""
		selected_hex = null
		hide_menus()
		return
	# Hide unit overlay
	unit_overlay_node.stop()
	current_unit_overlay_hex_name = ""
	selected_ant = null

	# Sprawdzenie czy aktualny gracz klika na wrogie terytorium czy na siebie i dopasowuje do tego kolor
	if single_map.get_field_owner(SingleMap.convert_name_to_coordinates(hex.get_name(), single_map.size)) == current_player:
		terrain_overlay_node.get_material().albedo_color = selection_hex_color_own
	else:
		terrain_overlay_node.get_material().albedo_color = selection_hex_color_enemy

	terrain_overlay_node.set_translation(hex.get_translation())
	terrain_overlay_node.set_scale(hex.get_scale() * Vector3(1,0.5,1))
	terrain_overlay_node.reset()
	terrain_overlay_node.start()
	current_terrain_overlay_hex_name = hex.get_name()
	selected_hex = hex
	show_buildings_menu()
	$HUD/HUD/Buildings/VBox/Label.set_text("hex menu - field " + str(SingleMap.convert_name_to_coordinates(hex.get_name(), single_map.size).to_string()))


# TODO może dodać tutaj info czy jest to menu gracza czy wroga?
func show_buildings_menu():
	$HUD/HUD/Buildings.show()
	$HUD/HUD/Units.hide()


func show_units_menu():
	$HUD/HUD/Units.show()
	$HUD/HUD/Buildings.hide()


func hide_menus():
	$HUD/HUD/Buildings.hide()
	$HUD/HUD/Units.hide()

func get_active_players() -> int:
	var count : int = 0 
	for i in players_activite:
		count += 1
	
	return count

func try_to_end_turn() -> void:
	confirmation_dialog.popup()
	

func end_turn() -> void:
	# TODO Jeśli to jest tura gracza to może to kliknąć, w przeciwnym wypadku nie wyjść z funkcji
	print("Koniec tury")
	
	var new_turn : bool = false
	var curr : int = current_player
	# TODO Usunąć pętlę while_true, ponieważ na chwilę obecną funkcje
	while true:
		if  get_active_players() == 1:
			print("Wygrana") # TODO, dodać okno z wygraną czy porażką czy coś takiego
			return
		
		
		# TODO Here update resources
		single_map.add_resources(player_resources[curr], single_map.calculate_end_turn_resources_change(curr))
		$HUD/HUD/Resources.update_resources(player_resources[curr])
		
		curr = (curr + 1) % number_of_start_players
		if curr == 0:
			new_turn = true
	
		assert(curr != current_player) # To by znaczyło że nie znaleziono żadnego gracza innego od aktualnego
		if players_activite[curr]:
			current_player = curr
			if players_type[curr] == PLAYERS_TYPE.CPU:
				# TODO wykonać tury dla użytkownika CPU
				pass
			elif players_type[curr] == PLAYERS_TYPE.HUMAN:
				break # Tura gracza
	
	# Aktualizacja koloru gracz na mapie
	$HUD/HUD.update_current_player_text_color(current_player)
	print("Current player " + str(current_player))
	if new_turn:
		round_label.set_text(str(int(round_label.get_text()) + 1))
	
	# TODO Update resources
	hide_menus()
	terrain_overlay_node.stop()
	unit_overlay_node.stop()
	current_unit_overlay_hex_name = ""
	current_terrain_overlay_hex_name = ""
