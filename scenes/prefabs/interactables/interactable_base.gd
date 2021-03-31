extends Spatial

onready var _player_in_range: bool = false
onready var _player_is_focused: bool = false

func _input(event):
	if Input.is_action_pressed("interact") and _player_is_focused:
		_on_action()

func _on_outer_area_body_entered(body):
	if body.is_in_group("player"):
		_player_in_range = true
		_on_player_enter_range()

func _on_outer_area_body_exited(body):
	if _player_in_range:
		_player_in_range = false
		_on_player_exit_range()

func _on_inner_area_area_entered(area):
	_on_inner_entered(area)
	
func _on_inner_area_body_entered(body):
	_on_inner_entered(body)

func _on_inner_entered(node: Node) -> void:
	if node.is_in_group("interactible_area") && not _player_is_focused:
		_player_is_focused = true
		_on_interact_state_changed()


func _on_inner_area_area_exited(area):
	_on_inner_exited(area)
	
func _on_inner_area_body_exited(body):
	_on_inner_exited(body)
	
func _on_inner_exited(node: Node) -> void:
	if node.is_in_group("interactible_area") && _player_is_focused:
		_player_is_focused = false
		_on_interact_state_changed()
	
# overide stubs
func _on_action() -> void:
	pass

func _on_interact_state_changed() -> void:
	pass
	
func _on_player_enter_range() -> void:
	pass
	
func _on_player_exit_range() -> void:
	pass
