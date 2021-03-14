extends Control


const animation_show_logo:String = "show_logo"

var shown_splash: bool = false

func _ready():
	$animation_player.play(animation_show_logo) 
	if Game.ready:
		_attempt_game_launch() 
	else:
		Event.connect_signal(Event.GAME_INITIALISED, self, "_attempt_game_launch")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == animation_show_logo:
		shown_splash = true
		_attempt_game_launch()

func _attempt_game_launch():
	if shown_splash and Game.ready:
		Scene.change(Scene.MAIN_MENU)
