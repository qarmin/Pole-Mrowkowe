extends Node

onready var game_time: float = OS.get_ticks_msec()
const MAX_TEAMS: int = 4  # Służy do sprawdzania czy wszędzie zaaktualizowano tę liczbę gdzie tylko możliwe
enum GAME_TYPE { NO_TYPE, SKIRMISH, CAMPAIGN }
var game_type: int = GAME_TYPE.NO_TYPE  # game type
var single_map: SingleMap = null
var game_started: bool = false


func _process(delta: float) -> void:
	if game_started == true:
		game_time += delta


func get_current_play_time() -> float:
	return (game_time - OS.get_ticks_msec()) / 1000.0
