extends KinematicBody2D

const teleport_probability = .01

onready var world = get_parent()
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var timer = $Timer
onready var animationState = animationTree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .85

var rng = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())

func _get_debug():
	return "Pos: %s, St: %s" % [position.round(), State.keys()[current_state]]

func rng_direction():
	return rng.randf() - .5
enum State {IDLE, WALK, NEW_DIRECTION}

func _physics_process(_delta):
	match current_state:
		State.IDLE:
			animationState.travel("Idle")
		State.WALK:
			walk(motion)
		State.NEW_DIRECTION:
			motion = Vector2(rng_direction(), rng_direction())
			current_state = State.WALK
				
func walk(motion):
	animationTree.set("parameters/Idle/blend_position", motion.normalized())
	animationTree.set("parameters/Run/blend_position", motion.normalized())
	animationState.travel("Run")
	motion = motion.normalized() * motion_speed
	move_and_slide(motion)
	
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

func _on_Timer_timeout():
	timer.wait_time = 1
	teleport()
	current_state = rng.randi_range(0,State.size()-1)
	
