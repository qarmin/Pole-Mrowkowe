extends Node

onready var game_time: float = OS.get_ticks_msec()
const MAX_TEAMS: int = 4  # Służy do sprawdzania czy wszędzie zaaktualizowano tę liczbę gdzie tylko możliwe

enum GAME_TYPE { NO_TYPE, SKIRMISH, CAMPAIGN }

var game_type: int = GAME_TYPE.NO_TYPE  # game type
var single_map: SingleMap = null
var number_of_players: int = 0

var game_started: bool = false  # TODO add something to it


func _process(delta: float) -> void:
	if game_started == true:
		game_time += delta


func get_current_play_time() -> float:
	return (game_time - OS.get_ticks_msec()) / 1000.0


func load_game() -> void:
	assert(single_map != null)
	assert(number_of_players != 0)

	var loaded_game = load("res://Game/Game.tscn").instance()

	loaded_game.number_of_start_players = number_of_players
	loaded_game.single_map = single_map
	loaded_game.map_was_generated_before = true
	MapCreator.create_3d_map(single_map)
	loaded_game.add_child(single_map.map)

	var node_to_delete: Control
	for i in get_node("/root").get_children():
		if i is Control:
			node_to_delete = i

	node_to_delete.queue_free()
	get_node("/root").add_child(loaded_game)
#	assert(get_tree().change_scene_to(loaded_game) == OK)
