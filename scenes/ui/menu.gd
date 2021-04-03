extends Control

onready var contents = $contents/
onready var game_modes = $contents/game_modes
onready var settings = $contents/settings
onready var how_to_play = $contents/tut
onready var credits = $contents/credits

onready var start_wave_selection:OptionButton = $contents/game_modes/list/wave/select
onready var highscore:Label = $contents/game_modes/highscore/value
func _ready():
#	$AnimationPlayer.seek(0.5, true)
#	$AnimationPlayer.play_backwards("dip_to_black")
	NetworkHelper.connect("connected_to_server", self, "_connected_to_server")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for wave_num in Game.MAX_WAVES + 1:
		if wave_num != 0: 
			start_wave_selection.add_item(str(wave_num))
	var selected_index = Game.get_wave_selected_index()
	start_wave_selection.select(selected_index if selected_index >= 0 and selected_index < Game.MAX_WAVES else 0)
	highscore.text = str(Game.get_highscore())

func _on_single_player_on_pressed():
	$AnimationPlayer.play("dip_to_black")


func _on_Options_on_pressed():
	_show(settings)

func _on_Credits_on_pressed():
	_show(credits)

func _on_How_to_play_on_pressed():
	_show(how_to_play)

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

func _on_selected_item_selected(index):
	Game.set_wave_selected_index(index)


func _on_Host_on_pressed():
	NetworkHelper.host_server()
	Scene.change(Scene.MULTIPLAYER)


func _on_Join_on_pressed():
	$JoinGameDialog.show()


func _connected_to_server() -> void:
	Scene.change(Scene.MULTIPLAYER)
