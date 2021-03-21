extends VBoxContainer


func _ready():
	$full_screen/toggle.pressed = Game.player_data.video.full_screen
	$field_of_view_slider.value = Game.player_data.video.field_of_view

func _on_field_of_view_slider_value_changed(value):
	Game.set_field_of_view(value)

func _on_full_screen_toggled(on):
	Game.set_full_screen(on)
