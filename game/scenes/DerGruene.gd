extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
const RUN_MULT = 10
const max_return_counter = 10

onready var world = get_parent()
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var timer = $Timer
onready var animationState = animationTree.get("parameters/playback")

var rng = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())

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
	motion = motion.normalized() * MOTION_SPEED
	move_and_slide(motion)

func _on_Timer_timeout():
	timer.wait_time = 1
	current_state = rng.randi_range(0,State.size()-1)
