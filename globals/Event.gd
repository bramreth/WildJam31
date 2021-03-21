extends Node

const GAME_LOADED = "game_loaded"
const GAME_INITIALISED = "game_initialised"
const OPEN_DOORS = "open_doors"
const CLOSE_DOORS = "close_doors"

const ON_FULL_SCREEN_TOGGLED = "on_full_screen_toggled"
const ON_FIELD_OF_VIEW_CHANGED = "on_field_of_view_changed"

signal game_loaded(player_data)
signal game_initialised()
signal open_doors()
signal close_doors()

signal on_full_screen_toggle(toggled)
signal on_field_of_view_changed(value)

func connect_signal(signal_name:String, reference:Node, function:String):
		if connect(signal_name, reference, function):
			print("Event: Failed to connect signal: " + signal_name + "to " + reference.name + "." + function)
