extends Particles


func set_number_col(num: int, col: Color):
	process_material.scale = 2
	$Viewport/Label.text = str(num)
	$Viewport/Label.set("custom_colors/font_color", col)


func set_number_col_crit(num: int, col: Color):
	process_material.scale = 3
	$Viewport/Label.text = str(num) #+ "!"
	$Viewport/Label.set("custom_colors/font_color", col)
