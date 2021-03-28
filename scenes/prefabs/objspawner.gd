extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(15):
		var ball = $RigidBody.duplicate()
		ball.global_transform.origin.y -= x
		add_child($RigidBody.duplicate())
