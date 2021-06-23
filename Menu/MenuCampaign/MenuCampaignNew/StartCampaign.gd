extends Button


func _on_StartCampaign_button_up():
	GameSettings.message = """As a prince, you have been sent to the kingdom of ants,
	which is plagued by an evil prince who wants to conquer the area.
	Due to the fact that the kingdom is currently fighting in another war,
	your ranks have been joined by units of flying ants."""

	var single_map: SingleMap = SingleMap.new()

	single_map.size = Vector2j.new(3, 7)
	single_map.fields = [
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, 1, SingleMap.FIELD_TYPE.DEFAULT_FIELD],
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD],
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD],
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD],
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD],
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.NO_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD],
		[SingleMap.FIELD_TYPE.DEFAULT_FIELD, SingleMap.FIELD_TYPE.DEFAULT_FIELD, 0]
	]

	single_map.units = [[{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}]]
	single_map.nature = [[{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}]]
	single_map.number_of_all_possible_hexes = 7 * 3
	single_map.number_of_terrain = 7 * 3 - 2

	single_map.buildings = [[{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}], [{}, {}, {}]]

	single_map.add_unit(Vector2j.new(1, 0), Units.TYPES_OF_ANTS.SOLDIER, 1)
	single_map.add_unit(Vector2j.new(2, 6), Units.TYPES_OF_ANTS.FLYING, 1)

	single_map.building_add(Vector2j.new(1, 0), Buildings.TYPES_OF_BUILDINGS.ANTHILL, 1)
	single_map.building_add(Vector2j.new(2, 6), Buildings.TYPES_OF_BUILDINGS.ANTHILL, 1)

	GameSettings.single_map = single_map
	GameSettings.number_of_players = 2

	GameSettings.load_game()

	pass  # Replace with function body.
