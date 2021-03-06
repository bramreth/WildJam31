extends Node

const MAIN_MENU = "res://scenes/ui/menu.tscn"
const PLAYGROUND = "res://scenes/enviornments/playground.tscn"
const SAMCADE = "res://scenes/enviornments/samcade.tscn"
const MULTIPLAYER = "res://scenes/enviornments/multiplayer_compatible_level/GameWorld.tscn"
const STEAM_MULTIPLAYER = "res://scenes/enviornments/multiplayer_compatible_level/SteamGameWorld.tscn"

func init(scene_path:String) -> Node:
	return load(scene_path).instance()

func change(scene:String) -> void:
	if get_tree().change_scene(scene):
		print("Failed to load scene " + scene)
