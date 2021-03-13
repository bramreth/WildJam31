extends VBoxContainer

func _ready() -> void:
	$master_volume/toggle.pressed = not AudioServer.is_bus_mute(Game.master_bus_index)
	$master_volume_slider.value = db2linear(AudioServer.get_bus_volume_db(Game.master_bus_index))
	
	$background_volume/toggle.pressed = not AudioServer.is_bus_mute(Game.background_bus_index)
	$background_volume_slider.value = db2linear(AudioServer.get_bus_volume_db(Game.background_bus_index))
	
	$sfx_volume/toggle.pressed = not AudioServer.is_bus_mute(Game.sfx_bus_index)
	$sfx_volume_slider.value = db2linear(AudioServer.get_bus_volume_db(Game.sfx_bus_index))

#region audio
func _on_master_volume_slider_value_changed(value):
	Game.set_master_volume(value)

func _on_background_volume_slider_value_changed(value):
	Game.set_background_volume(value)

func _on_sfx_volume_slider_value_changed(value):
	Game.set_sfx_volume(value)

func _on_master_volume_toggled(on):
	Game.set_master_volume_active(on)

func _on_background_volume_toggled(on):
	Game.set_background_volume_active(on)

func _on_sfx_toggled(on):
	Game.set_sfx_volume_active(on)
#endregion
