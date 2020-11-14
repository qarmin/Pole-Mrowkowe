extends Node

var game_time: float = 0
const MAX_TEAMS: int = 4  # Służy do sprawdzania czy wszędzie zaaktualizowano tę liczbę gdzie tylko możliwe 
enum GAME_TYPE { SKIRMISH, CAMPAIGN }
var game_type: int  # game type
var single_map: SingleMap = null
var game_started: bool = false


func _process(delta: float) -> void:
	if game_started == true:
		game_time += delta
