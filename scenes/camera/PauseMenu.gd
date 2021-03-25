extends Control

func toggle_pause() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		unpause_game()
	else:
		pause_game()

func _input(event:InputEvent) -> void:
	if Game.debug and Input.is_action_just_pressed("debug"):
		toggle_pause()
		$debug.show_debug(get_tree().paused)
	if event.is_action_pressed("escape"):
		toggle_pause()


func pause_game() -> void:
	$AnimationPlayer.playback_speed = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$AnimationPlayer.play("pause")


func unpause_game() -> void:
	$AnimationPlayer.playback_speed = 1.5
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$AnimationPlayer.play_backwards("pause")
	$debug.show_debug(false)


func _on_Continue_pressed():
	unpause_game()


func _on_Settings_pressed():
	$main.hide()
	$settings_screen.show()

func _on_Reset_pressed():
	unpause_game()
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	unpause_game()
	Scene.change(Scene.MAIN_MENU)


func _on_settings_back_pressed():
	$main.show()
	$settings_screen.hide()
