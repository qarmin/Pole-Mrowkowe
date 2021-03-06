extends Spatial

var cpu_vs_cpu: bool = false  # Allow to have fully automated game

enum PLAYERS_TYPE { CPU = 0, HUMAN = 1 }

# USER_NORMAL - Zwykły ruch gracza
# CHOOSING_MOVE_PLACE - Użytkownik wybiera polę do którego chce przejść
# WAITING_FOR_END_OF_MOVING - Użytkownik czeka na zakończenie przesuwania się jednostki
# CPU_TURN - Tura komputera, na początku usuwane, dodawane są

enum STATUS { USER_NORMAL, CHOOSING_MOVE_PLACE, WAITING_FOR_END_OF_MOVING, CPU_TURN, GAME_ENDED }
var current_status = STATUS.USER_NORMAL

var number_of_start_players: int = 2  # Number of all players
var active_players: int = 3  # How many players still play
var current_player: int = 0  # Actual player
var players_activite: Array = []  #[true, true, false, true]  # Stan aktualny w graczach, czy ciągle żyją
var players_type: Array = []  #[PLAYERS_TYPE.HUMAN, PLAYERS_TYPE.HUMAN, PLAYERS_TYPE.CPU, PLAYERS_TYPE.CPU]
# TODO Maybe add players name?
var player_resources: Array = []

onready var round_node = $HUD/HUD/Round
onready var round_label = $HUD/HUD/Round/Label
onready var end_turn_dialog: ConfirmationDialog = $HUD/HUD/EndTurnDialog
onready var end_game_color_rect: ColorRect = $HUD/HUD/EndGameColorRect
onready var end_game_dialog: AcceptDialog = $HUD/HUD/EndGameDialog
onready var start_game_campaign_dialog: AcceptDialog = $HUD/HUD/StartGameCampaignDialog

var attacked_icon = load("res://HUD/AttackedIcon/AttackedIcon.tscn")

# Selection
var current_terrain_overlay_hex_name: String = ""
var current_unit_overlay_hex_name: String = ""

var selected_ant: Node = null
var selected_hex: Node = null
var selected_coordinates: Vector2j = null

var selection_ant_color_own: Color = Color("#6689d400")
var selection_ant_color_enemy: Color = Color("#2cd91515")

var selection_hex_color_own: Color = Color("#6689d400")
var selection_hex_color_enemy: Color = Color("#2cd91515")

var terrain_overlay_node: CSGTorus = preload("res://Overlay/TerrainOverlay.tscn").instance()
var unit_overlay_node: CSGTorus = preload("res://Overlay/UnitOverlay.tscn").instance()

var single_map: SingleMap

var ant_movement: Array = []
var ant_movement_overlay = preload("res://Overlay/PossiblePath/PossiblePathOverlay.tscn")

# Tablica z sąsiadami, musi być aktualizowana na bieżąco
var neighbourhood_array: Array = []
## Current coordinates

var map_was_generated_before: bool = false

# If it is ready and entered to tree, then only then everything can be initialized
var ready_and_entered: int = 0

const CPU_WAIT_TIME: float = 0.2
var cpu_wait_time: float = CPU_WAIT_TIME
var computer_removed_things: bool = false


func _process(delta: float) -> void:
	if ready_and_entered == 2:
		initialize_game()
		ready_and_entered = 100

	if current_status == STATUS.CPU_TURN:
		cpu_wait_time -= delta
		if cpu_wait_time < 0:
			cpu_wait_time = CPU_WAIT_TIME

			# Only once after
			if !computer_removed_things:
				computer_removed_things = true
				var removed_something: bool = false

				removed_something = removed_something || ai_remove_to_costly_units()
				removed_something = removed_something || ai_remove_to_costly_buildings()
				if !removed_something:
					ai_add_buildings()
					ai_add_units()

			if !ai_move_players():
				end_turn(false)


func can_player_do_things() -> bool:
	return current_status == STATUS.CHOOSING_MOVE_PLACE || current_status == STATUS.USER_NORMAL


func _enter_tree() -> void:
	ready_and_entered += 1


func _ready():
	ready_and_entered += 1


# Inicjalizuje wszystkie elementy
func initialize_game() -> void:
	# Pobiera dane z singletonu jeśli akurat nie były zapisane
	if GameSettings.game_data_set_before:
		number_of_start_players = GameSettings.number_of_players
		single_map = GameSettings.single_map
		map_was_generated_before = true
		MapCreator.create_3d_map(single_map)
		add_child(single_map.map)

	active_players = number_of_start_players
	current_player = 0
	for _i in range(number_of_start_players):
		players_activite.push_back(true)
		players_type.push_back(PLAYERS_TYPE.CPU)
		player_resources.push_back({"wood": 30, "gold": 30, "food": 30})

	players_type[0] = PLAYERS_TYPE.HUMAN  # First player is always a human

	for _i in range(6):
		var node: Spatial = ant_movement_overlay.instance()
		add_child(node)
		node.hide()
		ant_movement.append(node)

	if !map_was_generated_before:
		single_map = SingleMap.new()
		MapCreator.create_map(single_map, Vector2j.new(3, 3), 5)
#		MapCreator.populate_map_randomly_playable(single_map, 50, number_of_start_players)
		MapCreator.populate_map_realistically(single_map, number_of_start_players)
		MapCreator.create_3d_map(single_map)
		add_child(single_map.map)

	if GameSettings.message != "":
		start_game_campaign_dialog.set_text(GameSettings.message)
		start_game_campaign_dialog.show()
		GameSettings.message = ""

	# Ustawianie tutaj wielkości dozwolonego przez kamerę obszaru
	$Camera.set_camera_max_positions(single_map.size)

	# Aktualizacja koloru gracz na mapie
	$HUD/HUD.update_current_player_text_color(current_player, players_type[current_player])

	# Update resources
	gui_update_resources()

	# Water
	var water: Spatial = load("res://Terrain/Water/Water.tscn").instance()
	water.set_scale(Vector3(1000, 1, 1000))
	add_child(water)

	$Overlays.add_child(terrain_overlay_node)
	$Overlays.add_child(unit_overlay_node)
	for i in $Overlays.get_children():
		i.hide()

	end_game_dialog.set_exclusive(true)

	connect_clickable_signals()
	pass


func _input(event) -> void:
	# ESCAPE i prawy przycisk myszy umożliwiają przerwanie wybieranie miejsca gdzie można zaatakować
	if current_status == STATUS.CHOOSING_MOVE_PLACE:
#		if event is InputEventMouse &&  event.is_pressed():
#			if event.get_button_mask() == BUTTON_MASK_RIGHT:
#				current_status = STATUS.USER_NORMAL
#				hide_everything()
		if event is InputEventKey && event.is_pressed():
			if event.get_scancode() == KEY_ESCAPE:
				current_status = STATUS.USER_NORMAL
				hide_everything()


# Łączy wszystkie sygnały
func connect_clickable_signals() -> void:
	# Łączenie każdego pola oraz mrówki na mapie z funkcją wyświelającą
	for single_hex in $Map.get_children():
		assert(single_hex.get_name().begins_with("SingleHex"))
		if single_hex.connect("hex_clicked", self, "hex_clicked") != OK:
			assert(false)
		for thing in single_hex.get_children():
			if !thing.get_name().begins_with("ANT"):
				continue
			if thing.connect("ant_clicked", self, "ant_clicked") != OK:
				assert(false)

	if $HUD/HUD/Buildings.connect("upgrade_clicked", self, "handle_upgrade_building_click") != OK:
		assert(false)
	if $HUD/HUD/Buildings.connect("downgrade_clicked", self, "handle_downgrade_building_click") != OK:
		assert(false)
	if $HUD/HUD/Buildings.connect("create_unit_clicked", self, "handle_create_unit_click") != OK:
		assert(false)
	if $HUD/HUD/Units.connect("destroy_unit_clicked", self, "handle_destroy_unit_click") != OK:
		assert(false)
	if $HUD/HUD/Units.connect("move_unit_clicked", self, "handle_move_unit_click") != OK:
		assert(false)

	# TODO Po zakończeniu testów, zacząć pokazywać okno potwierdzające chęć zakończenia tury
#	round_node.connect("try_to_end_turn_clicked",self,"try_to_end_turn")
	round_node.connect("try_to_end_turn_clicked", self, "end_turn", [true])

	if end_turn_dialog.connect("confirmed", self, "end_turn", [true])  != OK:
		assert(false)

	if end_game_dialog.connect("confirmed", self, "end_game")  != OK:
		assert(false)


func end_game() -> void:
	if get_tree().change_scene("res://Start.tscn") != OK:
		assert(false)


func move_unit_3d(end_c: Vector2j, user_attack: bool):
	var type_of_attack: int
	if user_attack:
		type_of_attack = STATUS.USER_NORMAL
	else:
		type_of_attack = STATUS.CPU_TURN

	var start_c: Vector2j = selected_coordinates

#	var attacker_id : int = single_map.fields[start_c.y][start_c.x]
	var defender_id: int = single_map.fields[end_c.y][end_c.x]

	var start_units: int = single_map.units[start_c.y][start_c.x]["stats"]["ants"]
	var end_units: int = 0
	if !single_map.units[end_c.y][end_c.x].empty():
		end_units = single_map.units[end_c.y][end_c.x]["stats"]["ants"]

	var result = single_map.move_unit(start_c, end_c)

	var start_hex: Spatial = $Map.get_node(SingleMap.convert_coordinates_to_name(start_c, single_map.size))
	var end_hex: Spatial = $Map.get_node(SingleMap.convert_coordinates_to_name(end_c, single_map.size))

	if single_map.fields[end_c.y][end_c.x] != current_player:
		var attack_icon = attacked_icon.instance()
		attack_icon.show_icon(start_units, end_units, result.attacker_defeated, result.defender_defeated)
		end_hex.add_child(attack_icon)

	var anthill_name: String = Buildings.get_bulding_name(Buildings.TYPES_OF_BUILDINGS.ANTHILL)

	match result.result:
		# Stosowany również do przechodzenia na własne terytoria
		SingleMap.FIGHT_RESULTS.ATTACKER_WON_EMPTY_FIELD:
			var start_ant: Spatial = get_unit_from_field(start_c)
			start_hex.remove_child(start_ant)
			end_hex.add_child(start_ant)

			update_field_color(end_c)
			current_status = type_of_attack

			# Mrowisko musi zostać usunięte jeśli istnieje
			if result.defeated_enemy:
				if $Map.get_node(SingleMap.convert_coordinates_to_name(end_c, single_map.size)).has_node(anthill_name):
					$Map.get_node(SingleMap.convert_coordinates_to_name(end_c, single_map.size)).get_node(anthill_name).queue_free()
		SingleMap.FIGHT_RESULTS.ATTACKER_WON_KILLED_ANT:
			var end_ant: Spatial = get_unit_from_field(end_c)
			end_hex.remove_child(end_ant)
			end_ant.set_name("TO DELETE")
			end_ant.queue_free()

			var start_ant: Spatial = get_unit_from_field(start_c)
			start_hex.remove_child(start_ant)
			end_hex.add_child(start_ant)

			update_field_color(end_c)
			current_status = type_of_attack

			# Mrowisko musi zostać usunięte jeśli istnieje
			if result.defeated_enemy:
				if $Map.get_node(SingleMap.convert_coordinates_to_name(end_c, single_map.size)).has_node(anthill_name):
					$Map.get_node(SingleMap.convert_coordinates_to_name(end_c, single_map.size)).get_node(anthill_name).queue_free()
		SingleMap.FIGHT_RESULTS.DEFENDER_WON:
			get_unit_from_field(start_c).queue_free()
			current_status = type_of_attack
		SingleMap.FIGHT_RESULTS.DRAW_BOTH_ANT_DEAD:
			get_unit_from_field(start_c).queue_free()
			get_unit_from_field(end_c).queue_free()
			current_status = type_of_attack
		SingleMap.FIGHT_RESULTS.DRAW_BOTH_ANT_LIVE:
			current_status = type_of_attack
		_:
			assert(false, "Missing fight result")

	if result.defeated_enemy:
		players_activite[defender_id] = false
		for coord in result.changed_fields:
			update_field_color(coord)

	gui_update_resources()
	hide_everything()
	check_win()


func ant_clicked(ant: AntBase) -> void:
	# Tura CPU
	if !can_player_do_things():
		return

	var parent_name: String = ant.get_parent().get_name()
#	print("Ant " + parent_name + "/" + ant.get_name() + " was clicked and this was handled!")

	if current_status == STATUS.CHOOSING_MOVE_PLACE:
		var clicked_coordinates: Vector2j = SingleMap.convert_name_to_coordinates(parent_name, single_map.size)
		if Vector2j.is_in_array(neighbourhood_array, clicked_coordinates):
			move_unit_3d(clicked_coordinates, true)
			return
		else:
			current_status = STATUS.USER_NORMAL

	possible_ant_movements()

	# Jeśli mrówka była wcześniej kliknięta, to usuwamy zaznaczenie
	if parent_name == current_unit_overlay_hex_name:
		unit_overlay_node.stop()
		current_unit_overlay_hex_name = ""
		selected_ant = null
		hide_menus()
		current_status = STATUS.USER_NORMAL
		return

	# Na wszelki wypadek odznaczamy zaznaczenie na terenie
	terrain_overlay_node.stop()
	current_terrain_overlay_hex_name = ""
	selected_hex = null

	var coordinates: Vector2j = SingleMap.convert_name_to_coordinates(parent_name, single_map.size)

	selected_coordinates = coordinates

	# Sprawdzenie czy aktualny gracz klika na wroga czy na siebie i dopasowuje do tego kolor
	if single_map.get_field_owner(coordinates) == current_player:
		unit_overlay_node.get_material().albedo_color = selection_ant_color_own
	else:
		unit_overlay_node.get_material().albedo_color = selection_ant_color_enemy
		possible_ant_movements()

	unit_overlay_node.set_translation(ant.get_translation() + ant.get_parent().get_translation())
	unit_overlay_node.set_scale(ant.get_scale())
	unit_overlay_node.reset()
	unit_overlay_node.start()
	current_unit_overlay_hex_name = parent_name
	selected_ant = ant
	show_units_menu()
	gui_update_units()
	$HUD/HUD/Units/VBox/Header/Label.set_text("unit menu - field " + coordinates.to_string())


# TODO - tylko powinno być to widoczne gdy gracz naciśnie na przycisk przemieszczania się
func possible_ant_movements(array_of_coordinates: Array = [], hide: bool = true) -> void:
	if hide:
		for i in ant_movement:
			i.hide()
		return

	for i in range(6):
		if i < array_of_coordinates.size():
			ant_movement[i].get_parent().remove_child(ant_movement[i])

			get_node("Map").get_node(SingleMap.convert_coordinates_to_name(array_of_coordinates[i], single_map.size)).add_child(ant_movement[i])
			ant_movement[i].show()

#			print("Possible ant movements " + array_of_coordinates[i].to_string())
#			print(SingleMap.convert_coordinates_to_name(array_of_coordinates[i], single_map.size))
		else:
			ant_movement[i].hide()
	for coordinates in array_of_coordinates.size():
		pass
	pass


func hex_clicked(hex: SingleHex) -> void:
	# Tura CPU
	if !can_player_do_things():
		return

	if current_status == STATUS.CHOOSING_MOVE_PLACE:
		var clicked_coordinates: Vector2j = SingleMap.convert_name_to_coordinates(hex.get_name(), single_map.size)
		if Vector2j.is_in_array(neighbourhood_array, clicked_coordinates):
			move_unit_3d(clicked_coordinates, true)
			return
		else:  # Kliknięto na nieprawidłowy hex
			current_status = STATUS.USER_NORMAL

	possible_ant_movements()

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

	var coordinates: Vector2j = SingleMap.convert_name_to_coordinates(hex.get_name(), single_map.size)

	selected_coordinates = coordinates

	# Sprawdzenie czy aktualny gracz klika na wrogie terytorium czy na siebie i dopasowuje do tego kolor
	if single_map.get_field_owner(coordinates) == current_player:
		terrain_overlay_node.get_material().albedo_color = selection_hex_color_own
	else:
		terrain_overlay_node.get_material().albedo_color = selection_hex_color_enemy

	terrain_overlay_node.set_translation(hex.get_translation())
	terrain_overlay_node.set_scale(hex.get_scale() * Vector3(1, 0.5, 1))
	terrain_overlay_node.reset()
	terrain_overlay_node.start()
	current_terrain_overlay_hex_name = hex.get_name()
	selected_hex = hex
	show_buildings_menu()
	gui_update_building_menu()
	$HUD/HUD/Buildings/VBox/Label.set_text("hex menu - field " + coordinates.to_string())  # Spacja jest potrzebna przed nazwą aby lepiej to wyglądało


# TODO może dodać tutaj info czy jest to menu gracza czy wroga?
func show_buildings_menu():
	$HUD/HUD/Buildings.show()
	$HUD/HUD/Units.hide()
	$HUD/HUD/MovingInfo.hide()


func show_units_menu():
	$HUD/HUD/Units.show()
	$HUD/HUD/Buildings.hide()
	$HUD/HUD/MovingInfo.hide()


func hide_menus():
	$HUD/HUD/Buildings.hide()
	$HUD/HUD/Units.hide()
	$HUD/HUD/MovingInfo.hide()


func hide_everything():
	hide_menus()
	possible_ant_movements()
	current_terrain_overlay_hex_name = ""
	current_unit_overlay_hex_name = ""
	selected_ant = null
	selected_hex = null
	selected_coordinates = null
	terrain_overlay_node.hide()
	unit_overlay_node.hide()


func get_active_players() -> int:
	var count: int = 0
	for i in players_activite:
		if i:
			count += 1

	return count


func check_win():
	if get_active_players() == 1 && players_activite[0]:
		current_status = STATUS.GAME_ENDED
		end_game_color_rect.show()

		end_game_dialog.get_label().set_text("You win game!")
		end_game_dialog.popup()

	elif !players_activite[0]:
		current_status = STATUS.GAME_ENDED
		end_game_color_rect.show()

		end_game_dialog.get_label().set_text("You lost game!")
		end_game_dialog.popup()


func try_to_end_turn() -> void:
	end_turn_dialog.popup()


func end_turn(only_player_can_end_turn: bool) -> void:
	if only_player_can_end_turn && !can_player_do_things():
		# To nie jest tura gracza a on chce to kliknąć
		return

#	print("Koniec tury")

	var new_turn: bool = false
	var curr: int = current_player

	Resources.add_resources(player_resources[curr], single_map.calculate_end_turn_resources_change(curr))
	Resources.normalize_resources(player_resources[curr])  # Prevents from being resource smaller than 0

	while true:
		curr = (curr + 1) % number_of_start_players
		if curr == 0:
			new_turn = true
		if players_activite[curr]:
			break

	assert(curr != current_player)  # To by znaczyło że nie znaleziono żadnego gracza innego od aktualnego

	current_player = curr
	if players_type[curr] == PLAYERS_TYPE.CPU:
		current_status = STATUS.CPU_TURN
		computer_removed_things = false
	elif players_type[curr] == PLAYERS_TYPE.HUMAN:
		current_status = STATUS.USER_NORMAL

	# Aktualizacja zasobów
	gui_update_resources()
	# Reset ruchu mrówek
	restore_ant_movement_ability()
	# Aktualizacja koloru gracz na mapie
	$HUD/HUD.update_current_player_text_color(current_player, players_type[current_player])
#	print("Current player " + str(current_player))
	if new_turn:
		round_label.set_text(str(int(round_label.get_text()) + 1))

	hide_everything()


func gui_update_resources() -> void:
	$HUD/HUD/Resources.update_resources(player_resources[current_player], single_map.calculate_end_turn_resources_change(current_player))


func gui_update_building_menu() -> void:
	if single_map.fields[selected_coordinates.y][selected_coordinates.x] == current_player:  # Re-enable this after tests
		$HUD/HUD/Buildings.update_buildings_info(player_resources[current_player], single_map.buildings[selected_coordinates.y][selected_coordinates.x], selected_coordinates, single_map)
	else:
		$HUD/HUD/Buildings.hide()


func gui_update_units() -> void:
	if single_map.fields[selected_coordinates.y][selected_coordinates.x] == current_player:  # Re-enable this after tests
		$HUD/HUD/Units.update_units_info(single_map.units[selected_coordinates.y][selected_coordinates.x], selected_coordinates, single_map)
	else:
		$HUD/HUD/Units.hide()


func handle_move_unit_click() -> void:
	if single_map.units[selected_coordinates.y][selected_coordinates.x]["stats"]["number_of_movement"] > 0:
		$HUD/HUD/MovingInfo.show()
		current_status = STATUS.CHOOSING_MOVE_PLACE
		neighbourhood_array = single_map.get_neighbourhoods(selected_coordinates, current_player)
		possible_ant_movements(neighbourhood_array, false)


func handle_destroy_unit_click() -> void:
	hide_menus()
	possible_ant_movements()
	unit_overlay_node.hide()

	assert(current_player == single_map.fields[selected_coordinates.y][selected_coordinates.x])  # Użytkownik musi posiadać to pole aby tworzyć na nim jednostki
	assert(!single_map.units[selected_coordinates.y][selected_coordinates.x].empty())  # Pole musi posiadać jednostkę

	var qq = single_map.units[selected_coordinates.y][selected_coordinates.x]
	var type_of_unit = qq["type"]
	var unit_name: String = Units.get_unit_name(type_of_unit)

	$Map.get_node(SingleMap.convert_coordinates_to_name(selected_coordinates, single_map.size)).get_node("ANT" + unit_name).queue_free()

	var resources_to_build: Dictionary = Units.get_unit_to_build(type_of_unit, 1)
	Resources.scale_resources(resources_to_build, Units.DOWNGRADE_COST)
	Resources.add_resources(player_resources[current_player], resources_to_build)

	assert(Resources.are_all_resources_positive(player_resources[current_player]))

	# We must entirelly remove unit
	single_map.remove_unit(selected_coordinates)

#	print("Removed unit " + Units.get_unit_name(type_of_unit))
	gui_update_building_menu()
	gui_update_resources()
	pass


func handle_create_unit_click(type_of_unit: int) -> void:
	Units.validate_type(type_of_unit)
	assert(current_player == single_map.fields[selected_coordinates.y][selected_coordinates.x])  # Użytkownik musi posiadać to pole aby tworzyć na nim jednostki
	assert(single_map.units[selected_coordinates.y][selected_coordinates.x].empty())  # Pole nie może posiadać na sobie żadnej jednostki

	var unit_3d: Spatial

	match type_of_unit:
		Units.TYPES_OF_ANTS.FLYING:
			unit_3d = MapCreator.AntFlying.instance()
		Units.TYPES_OF_ANTS.SOLDIER:
			unit_3d = MapCreator.AntSoldier.instance()
		Units.TYPES_OF_ANTS.WORKER:
			unit_3d = MapCreator.AntWorker.instance()
		_:
			assert(false, "Missing type of unit")

	unit_3d.translation = Vector3(0, 1.192, 0)
	$Map.get_node(SingleMap.convert_coordinates_to_name(selected_coordinates, single_map.size)).add_child(unit_3d)

	# Connect
	if unit_3d.connect("ant_clicked", self, "ant_clicked") != OK:
		assert(false)

	single_map.add_unit(selected_coordinates, type_of_unit, 1)

	var resources_to_build = Units.get_unit_to_build(type_of_unit, 1)
	Resources.remove_resources(player_resources[current_player], resources_to_build)
	assert(Resources.are_all_resources_positive(player_resources[current_player]))

	unit_3d.find_node("Outfit").set_surface_material(0, MapCreator.ant_texture_array[current_player])

#	print("Created unit: " + Units.get_unit_name(type_of_unit))
	gui_update_building_menu()
	gui_update_resources()
	pass


func handle_upgrade_building_click(type_of_building: int) -> void:
	Buildings.validate_building(type_of_building)

	assert(current_player == single_map.fields[selected_coordinates.y][selected_coordinates.x])  # Użytkownik musi posiadać to pole aby na nim budować

	var level: int

	if single_map.building_is_built(selected_coordinates, type_of_building):
		# Building exits so we upgrade level
		level = single_map.building_get_level(selected_coordinates, type_of_building) + 1

		single_map.building_change_level(selected_coordinates, type_of_building, level)
	else:
		# Building doesn't exits, so we build it
		level = 1

		single_map.building_add(selected_coordinates, type_of_building, 1)

		var building_3d: Spatial

		match type_of_building:
			Buildings.TYPES_OF_BUILDINGS.ANTHILL:
				building_3d = MapCreator.Anthill.instance()
			Buildings.TYPES_OF_BUILDINGS.BARRACKS:
				building_3d = MapCreator.Barracks.instance()
			Buildings.TYPES_OF_BUILDINGS.FARM:
				building_3d = MapCreator.Farm.instance()
			Buildings.TYPES_OF_BUILDINGS.SAWMILL:
				building_3d = MapCreator.Sawmill.instance()
			Buildings.TYPES_OF_BUILDINGS.GOLD_MINE:
				building_3d = MapCreator.GoldMine.instance()
			Buildings.TYPES_OF_BUILDINGS.PILE:
				building_3d = MapCreator.Piles.instance()
			_:
				assert(false, "Missing type of building")
		building_3d.translation = single_map.building_get_place_where_is_building(selected_coordinates, type_of_building)

		$Map.get_node(SingleMap.convert_coordinates_to_name(selected_coordinates, single_map.size)).add_child(building_3d)

	var resources_to_build: Dictionary = Buildings.get_building_to_build(type_of_building, level)
	Resources.remove_resources(player_resources[current_player], resources_to_build)

	assert(Resources.are_all_resources_positive(player_resources[current_player]))

#	print("Upgrade " + Buildings.get_bulding_name(type_of_building))
	gui_update_building_menu()
	gui_update_resources()


func handle_downgrade_building_click(type_of_building: int) -> void:
	Buildings.validate_building(type_of_building)

	assert(current_player == single_map.fields[selected_coordinates.y][selected_coordinates.x])  # Użytkownik musi posiadać to pole aby na nim budować

	var level: int = single_map.building_get_level(selected_coordinates, type_of_building)
	assert(level >= 1 && level <= 3)

	if level > 1:
		# We just change level of building
		single_map.building_change_level(selected_coordinates, type_of_building, level - 1)
	else:
		# We must entirelly remove building
		single_map.building_remove(selected_coordinates, type_of_building)

		var building_name: String = Buildings.get_bulding_name(type_of_building)

		$Map.get_node(SingleMap.convert_coordinates_to_name(selected_coordinates, single_map.size)).get_node(building_name).queue_free()

	var resources_to_build: Dictionary = Buildings.get_building_to_build(type_of_building, level)
	Resources.scale_resources(resources_to_build, Buildings.DOWNGRADE_COST)
	Resources.add_resources(player_resources[current_player], resources_to_build)

	assert(Resources.are_all_resources_positive(player_resources[current_player]))

#	print("Downgrade " + Buildings.get_bulding_name(type_of_building))
	gui_update_building_menu()
	gui_update_resources()


# Uaktualnia kolor jednostki dla danego pola i hexa
func update_field_color(coordinates: Vector2j) -> void:
	assert(single_map.fields[coordinates.y][coordinates.x] != SingleMap.FIELD_TYPE.NO_FIELD)

	var name: String = SingleMap.convert_coordinates_to_name(coordinates, single_map.size)
	var hex_node: Node = $Map.get_node(name)

	if single_map.fields[coordinates.y][coordinates.x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
		hex_node.set_surface_material(0, MapCreator.texture_base)
		for i in hex_node.get_children():
			if i.get_name().begins_with("ANT"):
				i.find_node("Outfit").set_surface_material(0, MapCreator.ant_base)

	else:
		hex_node.set_surface_material(0, MapCreator.texture_array[current_player])
		for i in hex_node.get_children():
			if i.get_name().begins_with("ANT"):
				i.find_node("Outfit").set_surface_material(0, MapCreator.ant_texture_array[current_player])


#
#func check_if_on_field_is_unit(coordinates : Vector2j) -> bool:
#	for i in $Map.get_node(SingleMap.convert_coordinates_to_name(coordinates, single_map.size)).get_children():
#		if i.begins_with("ANT"):
#			return true
#	return false


func get_unit_from_field(coordinates: Vector2j) -> Spatial:
	for i in $Map.get_node(SingleMap.convert_coordinates_to_name(coordinates, single_map.size)).get_children():
		if i.get_name().begins_with("ANT"):
			return i
	assert(false)
	return Spatial.new()


func restore_ant_movement_ability():
	for y in single_map.size.y:
		for x in single_map.size.x:
			if single_map.fields[y][x] == current_player && !single_map.units[y][x].empty():
				var unit_type = single_map.units[y][x]["type"]
				single_map.units[y][x]["stats"]["number_of_movement"] = Units.get_default_stats(unit_type, 1)["number_of_movement"]


func _exit_tree():
	for i in ant_movement:
		i.queue_free()
	terrain_overlay_node.queue_free()
	unit_overlay_node.queue_free()
	single_map.reset()


#	for i in ant_movement:
#		i.queue_free()


func get_next_turn_resources(player: int) -> Dictionary:
	var to_return: Dictionary = player_resources[player].duplicate(true)
	Resources.add_resources(to_return, single_map.calculate_end_turn_resources_change(player))
	return to_return


func ai_add_units() -> void:
#	print("Adding Units")
	var temp_res: Dictionary = player_resources[current_player].duplicate(true)
	Resources.remove_resources(temp_res, {"wood": 50, "food": 50, "gold": 50})

	if !Resources.are_all_resources_positive(temp_res):
		return  # No resources to add unit

	var all_coordinates: Array = single_map.get_user_fields_array(current_player, true)

	for _i in range(3):
		var coordinate: Vector2j = all_coordinates[randi() % all_coordinates.size()]
		var unit_to_create: int = randi() % Units.TYPES_OF_ANTS.ANT_MAX

		if single_map.units[coordinate.y][coordinate.x].empty():
			temp_res = player_resources[current_player].duplicate(true)
			Resources.remove_resources(temp_res, Units.get_unit_to_build(unit_to_create, 1))

			var temp_res_2 = single_map.calculate_end_turn_resources_change(current_player)
			Resources.remove_resources(temp_res_2, Units.get_unit_usage(unit_to_create, 1))

			if Resources.are_all_resources_positive(temp_res) && Resources.are_all_resources_positive(temp_res_2):
				selected_coordinates = coordinate

				handle_create_unit_click(unit_to_create)


#				print_cpu_things("## Created Unit")


func ai_add_buildings() -> void:
#	print("Adding buildings")
	var temp_res: Dictionary = player_resources[current_player].duplicate(true)
	Resources.remove_resources(temp_res, {"wood": 50, "food": 50, "gold": 50})

	if !Resources.are_all_resources_positive(temp_res):
		return  # No resources to add building

	# Tylko buduj jeśli wszystkie surowce są na plusie
	var change_resources: Dictionary = single_map.calculate_end_turn_resources_change(current_player)
	if Resources.are_all_resources_positive(change_resources):
		var smallest_number: int = 1000000
		var building_to_build = Buildings.TYPES_OF_BUILDINGS.ANTHILL
		if change_resources["food"] < smallest_number:
			building_to_build = Buildings.TYPES_OF_BUILDINGS.FARM
			smallest_number = change_resources["food"]
		if change_resources["wood"] < smallest_number:
			building_to_build = Buildings.TYPES_OF_BUILDINGS.SAWMILL
			smallest_number = change_resources["wood"]
		if change_resources["gold"] < smallest_number:
			building_to_build = Buildings.TYPES_OF_BUILDINGS.GOLD_MINE
			smallest_number = change_resources["gold"]
		assert(smallest_number != 1000000)

		var all_coordinates: Array = single_map.get_user_fields_array(current_player)
		#
		for _i in range(5):
			var coordinate: Vector2j = all_coordinates[randi() % all_coordinates.size()]

			if single_map.building_get_place_for_build(coordinate) != -1:
				# Póki co się buduje, nie ulepsza
				if !single_map.building_is_built(coordinate, building_to_build):
					temp_res = player_resources[current_player].duplicate(true)
					Resources.remove_resources(temp_res, Buildings.get_building_to_build(building_to_build, 1))

					if Resources.are_all_resources_positive(temp_res):
						selected_coordinates = coordinate

						handle_upgrade_building_click(building_to_build)
#						print_cpu_things("## Built Building")
						break


# Usuwa budynki z pola gracza, zwraca true, jeśli coś usunęło
# MUSI zostać wykonany po usunięciu mrówek
func ai_remove_to_costly_buildings() -> bool:
	var removed_something: bool = false

	# Nie potrzeba usuwać budynku
	if Resources.are_all_resources_positive(get_next_turn_resources(current_player)):
		return removed_something

	## Zapisuje do tablicy informacje w formie {pozycja : typ_budynek}
	var player_buildings: Array = []
	var player_buildings_create_resources: Array = []

	for y in single_map.size.y:
		for x in single_map.size.x:
			if single_map.fields[y][x] == current_player:
				for building in single_map.buildings[y][x]:
					if building == Buildings.TYPES_OF_BUILDINGS.ANTHILL:
						pass  # Do nothing, cannot remove anthill
					elif building == Buildings.TYPES_OF_BUILDINGS.BARRACKS || building == Buildings.TYPES_OF_BUILDINGS.PILE:
						player_buildings.append({Vector2j.new(x, y): building})
					else:
						player_buildings_create_resources.append({Vector2j.new(x, y): building})

	for index in player_buildings.size():
		var data: Dictionary = player_buildings[index]
		var coordinates: Vector2j = data.keys()[0]
		var type: int = data.values()[0]

		removed_something = true
#		print_cpu_things("## REMOVED BUILDING PILES/BARRACKS")

		selected_coordinates = coordinates
		handle_downgrade_building_click(type)

		if Resources.are_all_resources_positive(get_next_turn_resources(current_player)):
			return removed_something

	if single_map.count_unit_number(current_player) >= 2:
		return removed_something

	for index in player_buildings_create_resources.size():
		var data: Dictionary = player_buildings_create_resources[index]
		var coordinates: Vector2j = data.keys()[0]
		var type: int = data.values()[0]

		removed_something = true
#		print_cpu_things("## REMOVED RESOURCE BUILDINGS")

		selected_coordinates = coordinates
		handle_downgrade_building_click(type)

		if Resources.are_all_resources_positive(get_next_turn_resources(current_player)):
			return removed_something

	return removed_something


# Usuwa jednostki z pola gracza, zwraca true, jeśli coś usunęło
func ai_remove_to_costly_units() -> bool:
	var removed_something: bool = false

	## Zapisuje do tablicy informacje w formie {pozycja : typ_mrówki}
	var player_units: Array = []

	# Nie potrzeba usuwać jednostek
	if Resources.are_all_resources_positive(get_next_turn_resources(current_player)):
		return removed_something

	for y in single_map.size.y:
		for x in single_map.size.x:
			if single_map.fields[y][x] == current_player:
				if !single_map.units[y][x].empty():
					player_units.append(Vector2j.new(x, y))

	# Nie trzeba usuwać mrówek jeśli jest ich 2 lub mniej
	if player_units.size() <= 2:
		return removed_something

	for index in player_units.size() - 2:
		var coordinates: Vector2j = player_units[index]

		selected_coordinates = coordinates

		handle_destroy_unit_click()

		removed_something = true
#		print_cpu_things("## REMOVED UNIT")

		if Resources.are_all_resources_positive(get_next_turn_resources(current_player)):
			return removed_something

	return removed_something


# Return if moved unit
func ai_move_players() -> bool:
	var units: Array = single_map.get_user_units_array(current_player)

	var unit_have_movement: bool = false

	for index in units.size():
		var coordinates: Vector2j = units[index]
		if single_map.units[coordinates.y][coordinates.x]["stats"]["number_of_movement"] > 0:
#			print("Moving unit TODO")
			var array_of_fields: Array = ai_get_array_of_closest_fields(coordinates)
			if !array_of_fields.empty():
				selected_coordinates = coordinates
				move_unit_3d(array_of_fields[array_of_fields.size() - 1], false)
				unit_have_movement = true
				break  # Only one movement - at time, need to cooldown

	return unit_have_movement


# Pobiera informacje o najbliższych hexach z którymi sąsiaduje dany
func ai_get_array_of_closest_fields(unit_coordinates: Vector2j) -> Array:
	var NoneValue: int = -10000

	# Array to check

	var map_created: Array = []

	for y in single_map.size.y:
		map_created.append([])
		for x in single_map.size.x:
			var value: int = 0
			if single_map.fields[y][x] == SingleMap.FIELD_TYPE.NO_FIELD:
				value = NoneValue
			else:
				# Cannot move to field when already unit is there
				if single_map.fields[y][x] == current_player && !single_map.units[y][x].empty():
					value = NoneValue
				else:
					value = 10000000

			map_created[y].append(value)
			pass

	map_created[unit_coordinates.y][unit_coordinates.x] = 0

#	single_map.print_map(map_created)

	var to_check: Array = [unit_coordinates]
	var to_check_value: Array = [0]

	var help_array = [[[0, -1], [1, -1], [-1, 0], [1, 0], [0, 1], [1, 1]], [[-1, -1], [0, -1], [-1, 0], [1, 0], [-1, 1], [0, 1]]]

	while !to_check.empty():
		var current_element: Vector2j = to_check.pop_front()
		var current_value: int = to_check_value.pop_front()

		for h in [0, 1]:
			if current_element.y % 2 == ((h + 1) % 2):
				for i in range(6):
					if (
						(current_element.x + help_array[h][i][0] >= 0)
						&& (current_element.x + help_array[h][i][0] < map_created[0].size())
						&& (current_element.y + help_array[h][i][1] >= 0)
						&& (current_element.y + help_array[h][i][1] < map_created.size())
					):
						var cep_x = current_element.x + help_array[h][i][0]
						var cep_y = current_element.y + help_array[h][i][1]

						if map_created[cep_y][cep_x] > current_value:
							map_created[cep_y][cep_x] = current_value + 1
							to_check.append(Vector2j.new(cep_x, cep_y))
							to_check_value.append(current_value + 1)

	# Gdzie się znajduje najbliższy
	var closest_enemy_terrain: Vector2j
	var closest_terrain_value: int = 10000

	for y in single_map.size.y:
		for x in single_map.size.x:
			if single_map.fields[y][x] != current_player && map_created[y][x] != NoneValue:
				if map_created[y][x] < closest_terrain_value:
					closest_enemy_terrain = Vector2j.new(x, y)
					closest_terrain_value = map_created[y][x]
				elif map_created[y][x] == closest_terrain_value:  # Allot to choose more random fields
					if randi() % 2:
						closest_enemy_terrain = Vector2j.new(x, y)
						closest_terrain_value = map_created[y][x]

#	single_map.print_map(map_created)

	# Przeciwnik nie może nigdzie się ruszyć bo jest przyblokowany przez inne jednostki
	if closest_terrain_value == 10000:
#		print("Exiting")
		return []

#	print("Najbliższy przeciwnik " + closest_enemy_terrain.to_string()  + "         " + str(closest_terrain_value))

	var road_to_end: Array = [closest_enemy_terrain]

	to_check = [closest_enemy_terrain]
	to_check_value = [closest_terrain_value]

	while !to_check.empty():
		var current_element: Vector2j = to_check.pop_front()
		var current_value: int = to_check_value.pop_front()

		var elements_to_choose: Array = []

		for h in [0, 1]:
			if current_element.y % 2 == ((h + 1) % 2):
				for i in range(6):
					if (
						(current_element.x + help_array[h][i][0] >= 0)
						&& (current_element.x + help_array[h][i][0] < map_created[0].size())
						&& (current_element.y + help_array[h][i][1] >= 0)
						&& (current_element.y + help_array[h][i][1] < map_created.size())
					):
						var cep_x = current_element.x + help_array[h][i][0]
						var cep_y = current_element.y + help_array[h][i][1]

						if map_created[cep_y][cep_x] == current_value - 1:
							elements_to_choose.append(Vector2j.new(cep_x, cep_y))

		if !elements_to_choose.empty():
			var random_element: Vector2j = elements_to_choose[randi() % elements_to_choose.size()]
#			print("CLOSEST" + closest_enemy_terrain.to_string())
#			print("HOW long" + str(current_value))
#
#			print("RANDOM " + random_element.to_string())

			if current_value != 1:
				road_to_end.append(random_element)
				to_check.append(random_element)
				to_check_value.append(current_value - 1)

#	for i in road_to_end.size():
#		print("Step " + str(i) + " " + road_to_end[i].to_string())

	return road_to_end


func print_cpu_things(text: String) -> void:
	print(text)
