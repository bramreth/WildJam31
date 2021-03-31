extends Spatial

const OPEN = "open"
const CLOSE = "close"

var _left_open:bool = false
var _right_open:bool = false

onready var _left_door_animation_player = get_node("door_frame/door_with_handle/AnimationPlayer")
onready var _right_door_animation_player = get_node("door_frame/door_no_handle/AnimationPlayer")

func _ready():
	Event.connect_signal(Event.OPEN_DOORS, self, "_on_open")
	Event.connect_signal(Event.CLOSE_DOORS, self, "_on_close")

func _on_open():
	if not _left_open:
		_left_door_animation_player.play(OPEN)
		_left_open = true
	if not _right_open:
		_right_door_animation_player.play(OPEN)
		_right_open = true

func _on_close():
	if _left_open:
		_left_door_animation_player.play(CLOSE)
		_left_open = false
	if _right_open:
		_right_door_animation_player.play(CLOSE)
		_right_open = false
	
func toggle_with_handle() -> void:
	if !_left_door_animation_player.is_playing():
		if _left_open:
			_left_door_animation_player.play(CLOSE)
			_left_open = false
		else:
			_left_door_animation_player.play(OPEN)
			_left_open = true

func toggle_without_handle() -> void:
	if !_right_door_animation_player.is_playing():
		if _right_open:
			_right_door_animation_player.play(CLOSE)
			_right_open = false
		else:
			_right_door_animation_player.play(OPEN)
			_right_open = true
