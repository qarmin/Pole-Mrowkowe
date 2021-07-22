extends Node

const colors: Array = [Color8(0x00, 0x98, 0x01), Color8(0x00, 0xa3, 0xa5), Color8(0xa6, 0x95, 0x43), Color8(0xb9, 0x88, 0xff), Color8(0xda, 0x53, 0x3c)]


func generate_preview_image(single_map: SingleMap, square_size: Vector2j = Vector2j.new(10, 10), border_size: int = 1) -> void:
#	print("Wygenerowałem podgląd dla mapy (" + str(single_map.size.x) + "," + str(single_map.size.y) + ")")
	var img: Image = Image.new()

	var current_color: Color

	# Przesunięcie obrazu gdy nie jest kwadratem, realna wielkość i zmienna pomocnicza, tak aby na końcu mapa znalazła się po środku
	var image_offset: Vector2j = Vector2j.new(0, 0)
	var real_size: Vector2j  # Rzeczywista wielkość mapy(nie musi być kwadratem)
	var max_number: int

	var odd_line_offset: int  # Przesunięcie w liniach parzystych
#	var square_size : Vector2j # Wielkość danego kwadratu - aktualny rozmiar jest równy (square_size - border_size)
#	var border_size : int = 1 # Wielkość krawędzi

	img.unlock()
#	square_size = Vector2j.new(10,10)
#
#	## Tworzenie mapy bez offsetu gdy nie jest kwadratem
# warning-ignore:integer_division
#	img.create(int(single_map.size.x) * square_size.x + square_size.x / 2 + border_size, int(single_map.size.y) * square_size.y + border_size, false, Image.FORMAT_RGBA8)
#	image_offset = Vector2j.new(0,0)

	## Tworzenie mapy z offsetem
	real_size = Vector2j.new(int(single_map.size.x) * square_size.x + square_size.x / 2 + border_size, int(single_map.size.y) * square_size.y + border_size)
	max_number = int(max(real_size.x, real_size.y))
	img.create(max_number, max_number, false, Image.FORMAT_RGBA8)
# warning-ignore:integer_division
# warning-ignore:integer_division
	image_offset = Vector2j.new((max_number - real_size.x) / 2, (max_number - real_size.y) / 2)

	img.lock()

	for y in range(single_map.size.y):
		for x in range(single_map.size.x):
			if single_map.fields[y][x] == SingleMap.FIELD_TYPE.NO_FIELD:
				continue
			if single_map.fields[y][x] == SingleMap.FIELD_TYPE.DEFAULT_FIELD:
				current_color = colors[0]
			else:
				current_color = colors[single_map.fields[y][x] + 1]

			if y % 2 == 1:
# warning-ignore:integer_division
				odd_line_offset = square_size.x / 2
			else:
				odd_line_offset = 0

			# Nie można narysować grubszej krawędzi od szerokości boku
			assert(border_size >= 0)
			assert(border_size < square_size.y)
			assert(border_size < square_size.x)

			## Wewnętrzne krawędzie, lewe i górne rysuje się wewnątrz kwadratu a dolne i po prawej na zewnątrz
			for i_y in range(square_size.y + border_size):
				for i_x in range(square_size.x + border_size):
					if i_x < border_size || i_y < border_size || i_x > square_size.x - 1 || i_y > square_size.y - 1:  # Rysuje krawędzie
						img.set_pixel(square_size.x * x + odd_line_offset + i_x + image_offset.x, square_size.y * y + i_y + image_offset.y, Color.BLACK)
					else:  # Wypełnia środek
						img.set_pixel(square_size.x * x + odd_line_offset + i_x + image_offset.x, square_size.y * y + i_y + image_offset.y, current_color)

	img.unlock()

	img.resize(1024, 1024, Image.INTERPOLATE_NEAREST)

	single_map.set_preview(img)

#	if img.save_png("res://GeneratedPreview.png") != OK:
#		push_error("Nastąpił błąd podczas zapisywania podglądu")
