extends Node

var game_time : float = 0
const MAX_TEAMS = 4 # Służy do sprawdzania czy wszędzie zaaktualizowano tę liczbę gdzie tylko możliwe 


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	game_time += delta
