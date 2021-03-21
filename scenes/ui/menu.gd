extends Control

onready var contents = $contents
onready var game_modes = $contents/game_modes
onready var settings = $contents/settings
onready var credits = $contents/credits

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_single_player_on_pressed():
	$AnimationPlayer.play("dip_to_black")
	
func _on_Options_on_pressed():
	_show(settings)

func _on_Credits_on_pressed():
	_show(credits)

func _on_Game_Mode_on_pressed():
	_show(game_modes)

func _on_Quit_on_pressed():
	get_tree().quit()

func _show(node:Control) -> void:
	for view in contents.get_children():
		if view != node:
			view.hide()
		else:
			view.show()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dip_to_black":
		Scene.change(Scene.SAMCADE)

func _on_social_meta_clicked(meta):
	OS.shell_open(meta)
