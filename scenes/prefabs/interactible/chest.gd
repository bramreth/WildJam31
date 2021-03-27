extends Spatial

var anim_origin

func open_chest():
	reset_lid()
	var imp = Vector3.UP*250
	imp.z += 15
	$body/aura.restart()
	$Particles.restart()
	$lid.apply_central_impulse(imp)
	$lid.angular_velocity.x = rand_range(10,20) 
	$reward_container/AnimationPlayer.play("reward")

func _ready():
	anim_origin = $lid.global_transform
	$reward_container/AnimationPlayer.seek(0, true)
	randomize()

func reset_lid():
	$Particles.emitting = false
	$lid.global_transform = anim_origin
	$reward_container/AnimationPlayer.seek(0, true)

func add_reward(inst):
	$reward_container.add_child(inst)
	inst.connect("taken", self, "reward_taken")
	
func reward_taken():
	$body/aura.emitting = false
	$body/aura/pickup.restart()
