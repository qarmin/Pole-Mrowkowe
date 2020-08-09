extends Node

var colors : Array = [
	Color8(0x00,0x98,0x01),
	Color8(0x00,0xa3,0xa5),
	Color8(0xa6,0x95,0x43),
	Color8(0x8a,0x50,0x00),
	Color8(0xda,0x53,0x3c)
]

func generate_preview_image(single_map : SingleMap) -> void:
	print("Wygenerowałem podgląd dla mapy (" + str(single_map.size.x) + "," + str(single_map.size.y) + ")")
	var img : Image = Image.new()
	img.create(int(single_map.size.x) * 2 + 1, int(single_map.size.y), false, Image.FORMAT_RGBA8)
	
	var current_color : Color
	var offset : int
	var offset_scale : Vector2j
	var border_size : int = 2
	
	
	
	img.unlock()
	offset_scale = Vector2j.new(10,10)
	img.create(int(single_map.size.x) * offset_scale.x + offset_scale.x / 2 + 1, int(single_map.size.y) * offset_scale.y + 1, false, Image.FORMAT_RGBA8)
	img.lock()
	for y in range(single_map.size.y):
		for x in range(single_map.size.x):
			
			if single_map.fields[y][x] == MapCreator.FIELD_TYPE.NO_FIELD:
				continue
			if single_map.fields[y][x] == MapCreator.FIELD_TYPE.DEFAULT_FIELD:
				current_color = colors[0]
			else:
				current_color = colors[single_map.fields[y][x] - MapCreator.FIELD_TYPE.PLAYER_FIRST + 1]
				
			if y % 2 == 1:
				offset = offset_scale.x / 2
			else:
				offset = 0
			
			# Nie można narysować grubszej krawędzi od szerokości boku
			assert(border_size < offset_scale.y) 
			assert(border_size < offset_scale.x)
			
			for i_y in range(offset_scale.y + 1):
				for i_x in range(offset_scale.x + 1):
					if border_size == 0:
						if i_x == 0 || i_y == 0 || i_x == offset_scale.x || i_y == offset_scale.y: # Rysuje lewą i górną krawędź
							img.set_pixel(offset_scale.x * x + offset + i_x,offset_scale.y * y + i_y,Color.black)
						else: # Wypełnia środek
							img.set_pixel(offset_scale.x * x + offset + i_x,offset_scale.y * y + i_y,current_color)
					else:
						if i_x <= border_size || i_y <= border_size || i_x >= offset_scale.x - border_size || i_y >= offset_scale.y - border_size: # Rysuje lewą i górną krawędź
							img.set_pixel(offset_scale.x * x + offset + i_x,offset_scale.y * y + i_y,Color.black)
						else: # Wypełnia środek
							img.set_pixel(offset_scale.x * x + offset + i_x,offset_scale.y * y + i_y,current_color)
				
				
	img.unlock()
	
	if img.save_png("res://GeneratedPreview.png") != OK:
		push_error("Nastąpił błąd podczas zapisywania podglądu")
	
	
	
	
	
	pass
