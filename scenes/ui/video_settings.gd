extends VBoxContainer

#var resolutions = [[1920, 1080], [3840, 2160], [2560, 1440]]

func _ready():
	$full_screen/toggle.pressed = Game.get_full_screen()
	$field_of_view_slider.value = Game.get_field_of_view()
#	var lod_res = Game.get_resolution()
#	for res in resolutions:
#		$resolution/OptionButton.add_item(str(res[0])+","+str(res[1]))
#		if lod_res is Vector2:
#			if lod_res == Vector2(res[0], res[1]):
##				Game.set_resolution(Vector2(res[0], res[1]))
#				$resolution/OptionButton.select($resolution/OptionButton.get_item_count() -1)
#		elif lod_res == "("+str(res[0])+", "+str(res[1])+")":
##			Game.set_resolution(Vector2(res[0], res[1]))
#			$resolution/OptionButton.select($resolution/OptionButton.get_item_count()-1 )

func _on_field_of_view_slider_value_changed(value):
	Game.set_field_of_view(value)

func _on_full_screen_toggled(on):
	Game.set_full_screen(on)


#func _on_OptionButton_item_selected(index):
#	print(resolutions[index])
#	Game.set_resolution(Vector2(resolutions[index][0], resolutions[index][1]))

	
