extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.play_background_audio(Game.AUDIO_TRACK_DEFAULT)

func _on_play_game_button_pressed():
	Scene.change(Scene.PLAYGROUND)
