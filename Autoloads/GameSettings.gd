extends Node

var game_time : float = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	game_time += delta
