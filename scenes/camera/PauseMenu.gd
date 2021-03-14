extends Control


#func _ready():
#	$AnimationPlayer.playback_speed = 5
#	unpause_game()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			unpause_game()
		else:
			pause_game()


func pause_game():
	$AnimationPlayer.playback_speed = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$AnimationPlayer.play("pause")


func unpause_game():
	$AnimationPlayer.playback_speed = 1.5
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$AnimationPlayer.play_backwards("pause")


func _on_Continue_pressed():
	unpause_game()


func _on_Settings_pressed():
	pass # Replace with function body.


func _on_Reset_pressed():
	unpause_game()
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	unpause_game()
	Scene.change(Scene.MAIN_MENU)
