extends Node

const GAME_LOADED = "game_loaded"
const GAME_INITIALISED = "game_initialised"
const OPEN_DOORS = "open_doors"
const CLOSE_DOORS = "close_doors"

signal game_loaded(player_data)
signal game_initialised()
signal open_doors()
signal close_doors()


func connect_signal(signal_name:String, reference:Node, function:String):
		if connect(signal_name, reference, function):
			print("Event: Failed to connect signal: " + signal_name + "to " + reference.name + "." + function)
