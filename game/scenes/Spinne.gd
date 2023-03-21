extends KinematicBody2D


signal has_attacked(damage, direction)

enum State {IDLE, WALK, NEW_DIRECTION, CHASE, ATTACK, COOLDOWN, SLEEP}

var random_number_generator = RandomNumberGenerator.new()
var current_state = State.SLEEP
var motion = Vector2.ZERO
var direction = Vector2(rng_direction(), rng_direction()).normalized()
var return_counter = 0
var player = null
var teleport_probability = .1
var damage = 1

onready var world = get_parent().get_parent()
onready var start_position = Vector2(rand_range(0, world.map_width), rand_range(0, world.map_height))
onready var animation_tree = $AnimationTree
onready var state_change_timer = $StateChangeTimer
onready var cooldown_timer = $CooldownTimer
onready var attack_timer = $AttackTimer
onready var chase_area = $ChaseArea
onready var attack_area = $AttackArea
onready var music = $MusicSpinne
onready var animation_state = animation_tree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .75
onready var animation_speed = christine.default_animation_speed * .75
onready var raycast = $RayCast2D


func _ready():
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	animation_tree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animation_tree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animation_tree.set("parameters/Chop/TimeScale/scale",animation_speed)

func _get_debug():
	return "Pos: %s, St: %s, TSC: %f" % [position.round(), State.keys()[current_state], state_change_timer.time_left]


func rng_direction():
	return random_number_generator.randf() - .5


func _physics_process(_delta):
	motion = direction * motion_speed
	
	raycast.cast_to = 100 * motion.normalized()
	if raycast.is_colliding():
		if raycast.get_collider() != christine:
			current_state = State.NEW_DIRECTION
	
	if chase_area.overlaps_body(christine):
		if current_state != State.CHASE:
			if current_state != State.ATTACK:
				state_change_timer.stop()
				current_state = State.CHASE
		
	if attack_area.overlaps_body(christine):
		if current_state != State.ATTACK:
			state_change_timer.stop()
			attack_timer.start(.6)
			emit_signal("has_attacked", damage, direction)
			current_state = State.ATTACK
	
	match current_state:
		State.IDLE:
			animation_state.travel("Idle")
		State.WALK:
			walk()
		State.NEW_DIRECTION:
			direction = Vector2(rng_direction(), rng_direction()).normalized()
			current_state = State.WALK
		State.CHASE:
			if chase_area.overlaps_body(christine):
				direction = (christine.position - position).normalized()
				walk()
			else:
				start_random_state_change_timer()
		State.ATTACK:
			attack()
		State.SLEEP:
			state_change_timer.stop()


func walk():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
	animation_state.travel("Walk")
	move_and_slide(motion)


func attack():
	animation_tree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	animation_state.travel("Chop")


func start_random_state_change_timer():
	current_state = random_number_generator.randi_range(0,2)
	state_change_timer.start(1)


func is_sleeping():
	return current_state == State.SLEEP


func _on_TimerCooldown_timeout():
	if current_state != State.COOLDOWN:
		pass
	if player == null:
		start_random_state_change_timer()
	else:
		current_state = State.CHASE


func _on_TimerStateChange_timeout():
	if player == null or current_state == State.COOLDOWN:
		teleport()
		start_random_state_change_timer()


func teleport():
	if randf() < teleport_probability:
		var vec = christine.position - position
		var half_size = get_viewport().size * 0.5
		var clamped_vec = Vector2 (
				clamp(vec.x, -half_size.x, half_size.x),
				clamp(vec.y, -half_size.y, half_size.y)
			)
		if clamped_vec != vec:
			position = christine.position + music.get("max_distance") * christine.direction
			direction = -christine.direction
			current_state = State.WALK
			


func _on_attack_timer_timeout():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animation_state.travel("Idle")
	#emit_signal("has_attacked", damage)
	cooldown_timer.start(5)
	current_state = State.COOLDOWN


func _on_Christine_deal_accepted():
	if is_sleeping():
		position = world.tilemap.map_to_world(start_position)
		scale = Vector2(.3,.3)
	scale += Vector2(.3,.3)
	damage += 1
	teleport_probability += .1
	start_random_state_change_timer()

