extends "res://scenes/characters/character.gd"

onready var camera:Camera = $camera/juicy_cam

func _ready():
	$camera.update_health(health, armor)
	
func add_dmg_anim(col, num, pos):
	$camera.set_enemy_dmg(col, num, pos)

func _physics_process(_delta: float) -> void:
	if dead: return
	if _hang_time > 1:
		damage(25)
		_hang_time = 0
		$camera.warp(true)
	input_direction = get_input_direction()
	if is_on_floor() and Input.is_action_just_pressed("move_jump"):
		_jump()
	if not $WalkCarpet.is_playing() and input_direction and is_on_floor():
		$AudioStreamPlayer3D2.pitch_scale = 1.5 + randf()/15
		$WalkCarpet.playback_speed = 0.2 + (current_speed/ 20)
		$WalkCarpet.play("walk")

#region overrides
func calculate_move_direction() -> Vector3:
	var cam_xform:Transform = camera.get_global_transform()
	var move_direction:Vector3 = Vector3.ZERO
	move_direction += cam_xform.basis.z.normalized() * input_direction.z
	move_direction += cam_xform.basis.x.normalized() * input_direction.x
	move_direction.y = 0
	return move_direction.normalized()

func is_running() -> bool:
	var is_running = Input.is_action_pressed("move_sprint")
	$camera.sprint_spread_multiplier(is_running)
	return is_running
#region end

static func get_input_direction() -> Vector3:
	return Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0, Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))

func set_cam_env(env):
	$camera.set_cam_env(env)

func _jump() -> void:
	velocity.y = jump_force
	current_snap = Vector3.ZERO

func add_health(health_in: int):
	health = clamp(health + health_in, 0, max_health)
	$camera.update_health(health, armor)
	
func add_armor(armor_in: int):
	armor = clamp(armor + armor_in, 0, max_armor)
	$camera.update_health(health, armor)
	

func damage(amount:int, knockback:Vector3 = Vector3.ZERO) -> void:
	.damage(amount, knockback)
	camera.add_trauma(0.6)
	$camera.update_health(health, armor)
	

func _on_death() -> void:
	dead = true
	$AnimationPlayer.play("die")
	$camera.fade_out()
	Event.emit_signal("on_game_over_wave_reached", get_tree().get_nodes_in_group('level').front().wave)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		get_tree().reload_current_scene()
