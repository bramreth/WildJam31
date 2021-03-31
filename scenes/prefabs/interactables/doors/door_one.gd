extends "res://scenes/prefabs/interactables/interactable_base.gd"

onready var with_handle = false #this could be better...

func _on_action() -> void:
	if with_handle:
		$door.toggle_with_handle()
	else:
		$door.toggle_without_handle()

func _on_interact_state_changed() -> void:
	pass
	
func _on_player_enter_range() -> void:
	pass
	
func _on_player_exit_range() -> void:
	pass


func _on_with_handle_area_entered(area):
	with_handle = true
	_on_inner_area_area_entered(area)


func _on_door_no_handle_entered(area):
	with_handle = false
	_on_inner_area_area_entered(area)
