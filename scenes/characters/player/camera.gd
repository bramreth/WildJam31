extends "res://scenes/camera/camera.gd"

const MOUSE_SENSITIVITY:float = 0.05
onready var player:KinematicBody = get_parent()

func _ready() -> void:
	Input.warp_mouse_position(Vector2(512, 300))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta:float) -> void:
	if not Input.MOUSE_MODE_CAPTURED: return
	var joy_sensex = 4000
	var joy_sensey = 3000
	var x_look = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var y_look = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	x_look *= delta * joy_sensex
	y_look *= delta * joy_sensey
	rotate_x(deg2rad(y_look * MOUSE_SENSITIVITY * -1))
	player.rotate_y(deg2rad(x_look * MOUSE_SENSITIVITY * -1))
	var camera_rot = rotation_degrees
	camera_rot.x = clamp(camera_rot.x, -70, 70)
	rotation_degrees = camera_rot


func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		player.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		var camera_rot = rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_degrees = camera_rot
