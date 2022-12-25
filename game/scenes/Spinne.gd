extends KinematicBody2D


signal attacked

var random_number_generator = RandomNumberGenerator.new()
var current_state = State.SLEEP
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null
var teleport_probability = .01

onready var world = get_parent()
onready var position_spinne = Vector2(rand_range(0, world.map_width), rand_range(0, world.map_height))
onready var animation_tree = $AnimationTree
onready var state_change_timer = $TimerStateChange
onready var cooldown_timer = $TimerCooldown
onready var attack_timer = $TimerAttack
onready var music = $MusicSpinne
onready var animation_state = animation_tree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .75
onready var animation_speed = christine.default_animation_speed * .75


func _ready():
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	animation_tree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animation_tree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animation_tree.set("parameters/Chop/TimeScale/scale",animation_speed)

func _get_debug():
	return "Pos: %s, St: %s, TSC: %f" % [position.round(), State.keys()[current_state], state_change_timer.time_left]

func rng_direction():
	return random_number_generator.randf() - .5
enum State {IDLE, WALK, NEW_DIRECTION, CHASE, ATTACK, COOLDOWN, SLEEP}

func _physics_process(_delta):
	match current_state:
		State.IDLE:
			animation_state.travel("Idle")
		State.WALK:
			walk(motion)
		State.NEW_DIRECTION:
			motion = Vector2(rng_direction(), rng_direction())
			current_state = State.WALK
		State.CHASE:
			if player == null:
				start_random_state_change_timer()
			else:
				motion = position.direction_to(player.position)
				walk(motion)
		State.ATTACK:
			attack()
		State.COOLDOWN:
			pass
		State.SLEEP:
			state_change_timer.stop()

func walk(walk_motion):
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", walk_motion.normalized())
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", walk_motion.normalized())
	animation_state.travel("Walk")
	motion = motion.normalized() * motion_speed
	move_and_slide(motion)

func attack():
	attack_timer.start(.6)
	animation_tree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	animation_state.travel("Chop")
	cooldown_timer.start(5)
	state_change_timer.stop()
	current_state = State.COOLDOWN
	
func start_random_state_change_timer():
	current_state = random_number_generator.randi_range(0,2)
	state_change_timer.start(1)
	
func is_sleeping():
	return current_state == State.SLEEP

func _on_VisibilityNotifier2D_screen_entered():
	music.volume_db = 0

func _on_VisibilityNotifier2D_screen_exited():
	music.volume_db = -5

func _on_ChaseArea_Spinne_body_entered(body):
	if player == null and body.name == "Christine":
		player = body
		current_state = State.CHASE
		state_change_timer.stop()

func _on_ChaseArea_Spinne_body_exited(body):
	if player != null and body.name == "Christine" and current_state == State.CHASE:
		player = null
		start_random_state_change_timer()

func _on_AttackArea_Spinne_body_entered(body):
	animation_tree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	if body.name == "Christine":
		current_state = State.ATTACK
		emit_signal("attacked")

func _on_AttackArea_Spinne_body_exited(body):
	pass
	if body.name == "Christine" and current_state != State.COOLDOWN:
		current_state = State.CHASE

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
			position = christine.position + 2 * christine.motion

func _on_attack_timer_timeout():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animation_state.travel("Idle")

func _on_Christine_deal_accepted():
	if is_sleeping():
		position = world.tilemap.map_to_world(position_spinne)
		scale = Vector2(.3,.3)
	scale += Vector2(.3,.3)
	teleport_probability *= 2
	start_random_state_change_timer()

