extends Node
## Nie przydatne surowcne - Złoto(Gold) 
## Drewno(Wood), Kamień(Stone), Żelazo(Iron), Pożywienie(Food), Punkty Akcji(Action Points)
enum TYPE_OF_RESOURCE {WOOD, STONE, IRON, FOOD, ACTION_POINTS}

## Maksymalne poziomy nie muszą być wpisywane, lecz poprawiają czytelność(mam taką nadzieję)
const BUILDINGS_TYPES : PoolStringArray = PoolStringArray(["Home", "Barracks"])
const MAX_BUILDINGS_LEVEL : Dictionary = { "Home" : 3, "Barracks" : 2}
const BUILDINGS : Dictionary = { 	"Home" : [[1,2,3,4,5], [1,2,3,4,5], [1,2,3,4,5]],
								"Barracks" : [[1,2,3,4,5], [1,2,3,4,5]]}

const CITIES_TYPES : PoolStringArray = PoolStringArray(["Capital", "City", "Willage", "Sawmill", "Quarry", "Field"])
const MAX_CITY_LEVEL : Dictionary =  {"Capital" : 3, "City" : 2, "Willage" : 2, "Sawmill" : 2, "Quarry" : 2, "Field" : 2}
const CITIES : Dictionary = { 	"Capital" : [[1,2,3,4,5], [1,2,3,4,5], [1,2,3,4,5]],
								"City" : [[1,2,3,4,5], [1,2,3,4,5]],
								"Willage" : [[1,2,3,4,5], [1,2,3,4,5]],
								"Sawmill" : [[1,2,3,4,5], [1,2,3,4,5]],
								"Quarry" : [[1,2,3,4,5], [1,2,3,4,5]],
								"Field" :  [[1,2,3,4,5], [1,2,3,4,5]]}

const UNITS_TYPES : PoolStringArray = PoolStringArray(["Swordant", "Shieldant", "Bowant", "SpyAnt"])
const MAX_UNITS_LEVEL : Dictionary =  {"Swordant" : 3, "Shieldant" : 2, "Bowant" : 2, "SpyAnt" : 1}
const UNITS : Dictionary = { 	"Swordant" : [[1,2,3,4,5], [1,2,3,4,5], [1,2,3,4,5]],
								"Shieldant" : [[1,2,3,4,5], [1,2,3,4,5]],
								"Bowant" : [[1,2,3,4,5], [1,2,3,4,5]],
								"SpyAnt" : [[1,2,3,4,5]]}

############################################################### Produkcja

const BASE_FIELD_PRODUCTION : Array = [1,1,1,1,0]

const CITIES_PRODUCTION : Dictionary = { 	"Capital" : [[1,2,3,4,0],[1,2,3,4,0],[1,2,3,4,0]],
											"City" : [[1,2,3,4,0],[1,2,3,4,0]],
											"Willage" : [[1,2,3,4,0],[1,2,3,4,0]],
											"Sawmill" :  [[1,2,3,4,0],[1,2,3,4,0]],
											"Quarry" : [[1,2,3,4,0],[1,2,3,4,0]],
											"Field" : [[1,2,3,4,0],[1,2,3,4,0]]}
											
const BUILDINGS_PRODUCTION : Dictionary = { "Home" : [[1,2,3,4,0], [1,2,3,4,0], [1,2,3,4,0]],
											"Barracks" : [[1,2,3,4,0], [1,2,3,4,0]]}

################################################################ Ataki Specjalne
# Czas regeneracji w turach po użyciu
## GOD_HAND - Ręka boska - Leczy o 1 punkt życia wszystkie jednostki
## LAWNMOWER - Kosiarka - Odbiera 5 punktów każdej jednostce znajdującej się powyżej pewnej wysokości
## FLOOD - Potop - Odbiera 5 punktów każdej jednostce znajdującej się poniżej pewnej wysokości


const SPECIAL_ABILITIES : PoolStringArray = PoolStringArray([ "GOD_HAND", "LAWNMOWER", "FLOOD" ])
const SPECIAL_ABILITIES_COOLDOWN : Dictionary = { 	"GOD_HAND" : 30,
													"LAWNMOWER" : 25,
													"FLOOD" : 20}

func _ready() -> void:
	# Sprawdzanie poprawności poziomów budynków/jednostek itp.
	if BUILDINGS_TYPES.size() != BUILDINGS.size():
		printerr("Nieprawidłowa ilość elementów w Budynkach")
	if UNITS_TYPES.size() != UNITS.size():
		printerr("Nieprawidłowa ilość elementów w Użytkownikach")
	if CITIES_TYPES.size() != CITIES.size():
		printerr("Nieprawidłowa ilość elementów w Rodzajach Terenu")
		
	for i in BUILDINGS_TYPES:
		if BUILDINGS[i].size() != MAX_BUILDINGS_LEVEL[i]:
			printerr("Nieprawodłowa ilość stopni budynków w " + i)
			continue
		for j in BUILDINGS[i]:
			if j.size() != TYPE_OF_RESOURCE.size():
				printerr("Nieprawidłowa wartość zasobów w " + i)
	for i in CITIES_TYPES:
		if CITIES[i].size() != MAX_CITY_LEVEL[i]:
			printerr("Nieprawodłowa ilość stopni rozwoju miasta w " + i)
			continue
		for j in CITIES[i]:
			if j.size() != TYPE_OF_RESOURCE.size():
				printerr("Nieprawidłowa wartość zasobów w " + i)
	for i in UNITS_TYPES:
		if UNITS[i].size() != MAX_UNITS_LEVEL[i]:
			printerr("Nieprawodłowa ilość stopni jednostek w " + i)
			continue
		for j in UNITS[i]:
			if j.size() != TYPE_OF_RESOURCE.size():
				printerr("Nieprawidłowa wartość zasobów w " + i)
	
	# Sprawdznie poprawności produkcji bez punktów akcji
	if BASE_FIELD_PRODUCTION.size() != TYPE_OF_RESOURCE.size():
		printerr("Błąd w bazowej ilości produkcyjnej pola")
	
	for i in CITIES_TYPES:
		if CITIES_PRODUCTION[i].size() != (MAX_CITY_LEVEL[i]):
			print("Błąd w produkcji w poziomie rodzaju terenu: " + i)
		for j in CITIES_PRODUCTION[i]:
			if j.size() != TYPE_OF_RESOURCE.size():
				printerr("Błąd w produkcji wielkości zasobów dla różnych typów miast: " + i)
	for i in BUILDINGS_TYPES:
		if BUILDINGS_PRODUCTION[i].size() != (MAX_BUILDINGS_LEVEL[i]):
			print("Błąd w produkcji w poziomie rodzaju terenu: " + i)
		for j in BUILDINGS_PRODUCTION[i]:
			if j.size() != TYPE_OF_RESOURCE.size():
				printerr("Błąd w produkcji wielkości zasobów dla różnych typów miast: " + i)
		
	# Sprawdzenie poprawności czasu regeneracji "zaklęć"
	for i in SPECIAL_ABILITIES:
		if not SPECIAL_ABILITIES_COOLDOWN.has(i):
			printerr("Błąd w specjalnych zaklęciach")
	
