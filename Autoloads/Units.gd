extends Node

enum TYPES_OF_STATS {LIFE, ATTACK, DEFENSE, HAPPINESS, ACTION_POINTS, NUMBER_OF_MOVEMENT}
enum TYPES_OF_HELMETS {BRONZE, SILVER, GOLD}

const HELMETS_DEFENSE : PoolIntArray = PoolIntArray([2,4,6])


func _ready() -> void:
	assert(HELMETS_DEFENSE.size() == TYPES_OF_HELMETS.size())
	pass
