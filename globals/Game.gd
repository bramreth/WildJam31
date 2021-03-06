extends Node

const AUDIO_BUS_MASTER = "Master"
const AUDIO_BUS_BACKGROUND = "Background"
const AUDIO_BUS_SFX = "Sfx"
const AUDIO_DIRECTORY = "res://assets/audio/"
const AUDIO_TRACK_DEFAULT = "temp/Final Planck.wav"
const AUDIO_SOUND_HURT = "temp/hurt.wav"

const MAX_WAVES = 15

var debug = false
var continuous_waves = true

onready var master_bus_index = AudioServer.get_bus_index(AUDIO_BUS_MASTER)
onready var background_bus_index = AudioServer.get_bus_index(AUDIO_BUS_BACKGROUND)
onready var sfx_bus_index = AudioServer.get_bus_index(AUDIO_BUS_SFX)

onready var display:Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
onready var player_data:Dictionary
onready var ready:bool = false;

onready var background_audio_player := AudioStreamPlayer2D.new()
onready var sfx_audio_player := AudioStreamPlayer2D.new()

var hscore = 0

func _ready():
	Event.connect(Event.GAME_LOADED, self, "_on_game_loaded")

func _on_game_loaded(player_data:Dictionary) -> void:
	self.player_data = player_data
	ready = true	
	_set_up_video()
	_set_up_audio()
	Event.emit_signal(Event.GAME_INITIALISED)

#region game
func set_highscore(value):
	if value > player_data.game.highscore:
		player_data.game.highscore = value
		System.update_player_data(player_data)

func add_hscore(added):
	hscore += added
	set_highscore(hscore)
	
func start_level():
	hscore = 0

func get_highscore():
	return player_data.game.highscore
	
#func get_resolution():
#	return player_data.video.resolution

func set_wave_selected_index(wave):
	if wave >= 0 and wave < Game.MAX_WAVES:
		player_data.game.wave_selected = wave
		System.update_player_data(player_data)

func get_wave_selected_index():
	return player_data.game.wave_selected
	
func get_wave_selected():
	return player_data.game.wave_selected + 1
#endregion

#region video
func _set_up_video():
	OS.window_fullscreen = player_data.video.full_screen

func get_full_screen() -> bool:
	return OS.window_fullscreen

func set_full_screen(on) -> void:
	Event.emit_signal(Event.ON_FULL_SCREEN_TOGGLED, on)
	player_data.video.full_screen = on
	OS.window_fullscreen = on
	System.update_player_data(player_data)
	
#func set_resolution(res: Vector2):
#	var x = res[0]
#	var y = res[1]
#	OS.window_size = Vector2(x, y)
#	for v in get_tree().get_nodes_in_group("viewport"):
#		v.update_dim(Vector2(x, y))
#	player_data.video.resolution = Vector2(x, y)
#	System.update_player_data(player_data)
	
	
func get_field_of_view() -> bool:
	return player_data.video.field_of_view 
	
func set_field_of_view(value) -> void:
	Event.emit_signal(Event.ON_FIELD_OF_VIEW_CHANGED, value)
	player_data.video.field_of_view = value
	System.update_player_data(player_data)
#end region

#region audio
func _set_up_audio():
	AudioServer.set_bus_mute(master_bus_index, not player_data.audio.master_volume_on)
	AudioServer.set_bus_volume_db(master_bus_index, linear2db(player_data.audio.master_volume))
	AudioServer.set_bus_mute(background_bus_index, not player_data.audio.background_volume_on)
	AudioServer.set_bus_volume_db(background_bus_index, linear2db(player_data.audio.background_volume))
	AudioServer.set_bus_mute(sfx_bus_index, not player_data.audio.sfx_volume_on)
	AudioServer.set_bus_volume_db(sfx_bus_index, linear2db(player_data.audio.sfx_volume))
	
	background_audio_player.set_bus(AUDIO_BUS_BACKGROUND)
	background_audio_player.connect("finished", background_audio_player, "play")
	background_audio_player.autoplay = true
	background_audio_player.pause_mode = PAUSE_MODE_PROCESS
	add_child(background_audio_player)
	
	sfx_audio_player.set_bus(AUDIO_BUS_SFX)
	sfx_audio_player.autoplay = true
	sfx_audio_player.pause_mode = PAUSE_MODE_PROCESS
	add_child(sfx_audio_player)
	
func play_background_audio(track:String) -> void:
	background_audio_player.stream = load(AUDIO_DIRECTORY + track)
	background_audio_player.play()
		
func play_sfx_audio(track:String) -> void:
	sfx_audio_player.stream = load(AUDIO_DIRECTORY + track)
	sfx_audio_player.play()
	
func set_master_volume_active(on) -> void:
	AudioServer.set_bus_mute(master_bus_index, not on)
	player_data.audio.master_volume_on = on
	System.update_player_data(player_data)
	
func set_master_volume(value) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear2db(value))
	player_data.audio.master_volume = value
	System.update_player_data(player_data)
	
func set_background_volume_active(on) -> void:
	AudioServer.set_bus_mute(background_bus_index, not on)
	player_data.audio.background_volume_on = on
	System.update_player_data(player_data)
	
func set_background_volume(value) -> void:
	AudioServer.set_bus_volume_db(background_bus_index, linear2db(value))
	player_data.audio.background_volume = value
	System.update_player_data(player_data)
	
func set_sfx_volume_active(on) -> void:
	AudioServer.set_bus_mute(sfx_bus_index, not on)
	player_data.audio.sfx_volume_on = on
	System.update_player_data(player_data)

func set_sfx_volume(value) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear2db(value))
	player_data.audio.sfx_volume = value
	System.update_player_data(player_data)
#endregion
