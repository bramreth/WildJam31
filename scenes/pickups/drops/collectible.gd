extends Spatial

export (String) var ammo_name = ""
var player = null
var hud = null
var picking_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	hud = get_tree().get_nodes_in_group("hud").front()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if picking_up:
		global_transform.origin = global_transform.origin.linear_interpolate(player.global_transform.origin, delta * 16)
		global_transform.origin = global_transform.origin.linear_interpolate(player.global_transform.origin, delta * 16)

func collectible_effect():
	assert(false, "must be overloaded")
	
func can_collect():
	assert(false, "must be overloaded")

func _on_Area_body_entered(body):
	if not can_collect(): return
	$Particles.emitting = false
	collectible_effect()
	picking_up = true
	$pickup_container/bouncer.stop()
	$AnimationPlayer.play("pickup")

func spawn_anim():
	$AnimationPlayer.play("spawn_anim")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "pickup" or anim_name == "despawn":
		queue_free()
		
func despawn():
	$AnimationPlayer.play_backwards("despawn")
