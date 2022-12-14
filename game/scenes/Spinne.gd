extends KinematicBody2D

signal hasAttacked

onready var world = get_parent()
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var timerStateChange = $TimerStateChange
onready var timerCooldown = $TimerCooldown
onready var timerAttack = $TimerAttack
onready var music = $MusicSpinne
onready var animationState = animationTree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .75
onready var animation_speed = christine.default_animation_speed * .75

var rng = RandomNumberGenerator.new()
var current_state = State.SLEEP
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null
var teleport_probability = .01

func _ready():
	animationTree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Chop/TimeScale/scale",animation_speed)

func _get_debug():
	return "Pos: %s, St: %s, TSC: %f" % [position.round(), State.keys()[current_state], timerStateChange.time_left]

func rng_direction():
	return rng.randf() - .5
enum State {IDLE, WALK, NEW_DIRECTION, CHASE, ATTACK, COOLDOWN, SLEEP}

func _physics_process(_delta):
	match current_state:
		State.IDLE:
			animationState.travel("Idle")
		State.WALK:
			walk(motion)
		State.NEW_DIRECTION:
			motion = Vector2(rng_direction(), rng_direction())
			current_state = State.WALK
		State.CHASE:
			if player == null:
				timerRandomState()
			else:
				motion = position.direction_to(player.position)
				walk(motion)
		State.ATTACK:
			attack()
		State.COOLDOWN:
			pass
		State.SLEEP:
			timerStateChange.stop()

func walk(motion):
	animationTree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animationTree.set("parameters/Walk/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Walk")
	motion = motion.normalized() * motion_speed
	move_and_slide(motion)

func attack():
	timerAttack.start(.6)
	animationTree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Chop")
	timerCooldown.start(5)
	timerStateChange.stop()
	current_state = State.COOLDOWN
	
func timerRandomState():
	var randn = rng.randi_range(0,2)
	current_state = randn
	print('blah ', randn)
	timerStateChange.start(1)
	
func isSleeping():
	return current_state == State.SLEEP

func _on_VisibilityNotifier2D_screen_entered():
	music.volume_db = 0

func _on_VisibilityNotifier2D_screen_exited():
	music.volume_db = -5

func _on_ChaseArea_Spinne_body_entered(body):
	if player == null and body.name == "Christine":
		player = body
		current_state = State.CHASE
		timerStateChange.stop()

func _on_ChaseArea_Spinne_body_exited(body):
	if player != null and body.name == "Christine" and current_state == State.CHASE:
		player = null
		timerRandomState()

func _on_AttackArea_Spinne_body_entered(body):
	animationTree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	if body.name == "Christine":
		current_state = State.ATTACK
		emit_signal("hasAttacked")

func _on_AttackArea_Spinne_body_exited(body):
	pass
	if body.name == "Christine" and current_state != State.COOLDOWN:
		current_state = State.CHASE

func _on_TimerCooldown_timeout():
	if current_state != State.COOLDOWN:
		pass
	if player == null:
		timerRandomState()
	else:
		current_state = State.CHASE

func _on_TimerStateChange_timeout():
	if player == null or current_state == State.COOLDOWN:
		teleport()
		timerRandomState()

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

func _on_AttackTimer_timeout():
	animationTree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Idle")

func _on_Christine_DealAccepted():
	if isSleeping():
		position = world.tilemap.map_to_world(world.start_position_spinne)
		scale = Vector2(.3,.3)
	scale += Vector2(.3,.3)
	teleport_probability *= 2
	timerRandomState()
