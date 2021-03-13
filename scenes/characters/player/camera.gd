extends "res://scenes/camera/camera.gd"


const MOUSE_SENSITIVITY:float = 0.05
onready var player:KinematicBody = get_parent()


func _ready():
	Input.warp_mouse_position(Vector2(512, 300))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		player.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		var camera_rot = rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_degrees = camera_rot
