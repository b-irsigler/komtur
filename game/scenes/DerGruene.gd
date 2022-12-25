extends KinematicBody2D


signal conversation_started(active)

enum State {IDLE, WALK, NEW_DIRECTION, TALK}

const TELEPORT_PROBABILITY = .05

var rng = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())

onready var world = get_parent()
onready var start_position = Vector2(rand_range(0, world.map_width), rand_range(0, world.map_height))
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var timerStateChange = $TimerStateChange
onready var animationState = animationTree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .30


func _get_debug():
	return "Pos: %s, St: %s" % [position.round(), State.keys()[current_state]]


func rng_direction():
	return rng.randf() - .5


func _physics_process(_delta):
	match current_state:
		State.IDLE:
			animationState.travel("Idle")
		State.WALK:
			walk(motion)
		State.NEW_DIRECTION:
			motion = Vector2(rng_direction(), rng_direction())
			current_state = State.WALK
		#Talk is only a one-time-trigger
		State.TALK:
			talk()
			current_state = State.IDLE


func walk(walk_motion):
	animationTree.set("parameters/Idle/blend_position", walk_motion.normalized())
	animationTree.set("parameters/Run/blend_position", walk_motion.normalized())
	animationState.travel("Run")
	motion = motion.normalized() * motion_speed
	move_and_slide(walk_motion)


func teleport():
	if randf() < TELEPORT_PROBABILITY:
		var vec = christine.position - position
		var half_size = get_viewport().size * 0.5
		var clamped_vec = Vector2 (
				clamp(vec.x, -half_size.x, half_size.x),
				clamp(vec.y, -half_size.y, half_size.y)
			)
		if clamped_vec != vec:
			position = christine.position + 2 * christine.motion


func talk():
	var direction = christine.position - position
	animationTree.set("parameters/Idle/blend_position", direction.normalized())
	animationState.travel("Idle")
	emit_signal("conversation_started", true)


func _on_Timer_timeout():
	timerStateChange.wait_time = 1
	teleport()
	current_state = rng.randi_range(0,State.size()-2)


func _on_Area2D_body_entered(body):
	if body.name == "Christine":
		current_state = State.TALK
		timerStateChange.stop()


func _on_Area2D_body_exited(body):
	if body.name == "Christine":
		timerStateChange.start()
		emit_signal("started_conversation", false)


func _on_Christine_deal_accepted():
	current_state = State.WALK
	timerStateChange.start()


func _on_Christine_deal_denied():
	current_state = State.WALK
	timerStateChange.start()

