extends KinematicBody2D

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
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null

func _ready():
	animationTree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Chop/TimeScale/scale",animation_speed)

func _get_debug():
	return "Pos: %s, St: %s" % [position.round(), State.keys()[current_state]]

func rng_direction():
	return rng.randf() - .5
enum State {IDLE, WALK, NEW_DIRECTION, CHASE, ATTACK, COOLDOWN}

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
	
func timerRandomState():
	current_state = rng.randi_range(0,2)
	timerStateChange.start(1)

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
	if player != null and body.name == "Christine":
		player = null
		timerRandomState()

func _on_AttackArea_Spinne_body_entered(body):
	animationTree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	if body.name == "Christine":
		current_state = State.ATTACK

func _on_AttackArea_Spinne_body_exited(body):
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
		timerRandomState()

func _on_AttackTimer_timeout():
	animationTree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Idle")
	current_state = State.COOLDOWN
	timerCooldown.wait_time = 5
	timerCooldown.start()
	timerStateChange.stop()
