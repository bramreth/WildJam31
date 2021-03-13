extends Node

const MAIN = "res://scenes/ui/menu.tscn"
const PLAYGROUND = "res://scenes/enviornments/playground.tscn"

func init(scene_path:String) -> Node:
	return load(scene_path).instance()

func change(scene:String) -> void:
	if get_tree().change_scene(scene):
		print("Failed to load scene " + scene)
