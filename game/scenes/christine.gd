extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
const RUN_MULT = 10

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $Sprite
onready var timer  = $Timer
var running = false
var jump_height = 40
var jump_duration = 1
var motion = Vector2()

enum State {IDLE, WALK, RUN, JUMP}
var current_state = State.IDLE

func _physics_process(_delta):
	
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= float(2)
	motion = motion.normalized() * MOTION_SPEED
	
	if motion == Vector2.ZERO:
		current_state = State.IDLE
	elif current_state != State.JUMP:
		current_state = State.WALK
	
	if Input.is_action_just_pressed("run"):
		running = not running
	if Input.is_action_just_pressed("jump") and current_state != State.JUMP:
		current_state = State.JUMP
		timer.start()
		
	match current_state:
		State.IDLE:
			idle()
		State.WALK:
			if running:
				motion *= RUN_MULT
			walk(motion)
		State.JUMP:
			jump()
			
func idle():
	animationState.travel("Idle")
	
func walk(motion):
	animationTree.set("parameters/Idle/blend_position", motion.normalized())
	animationTree.set("parameters/Run/blend_position", motion.normalized())
	animationState.travel("Run")
	move_and_slide(motion)

func jump():
	animationState.travel("stop")
	var temp = timer.time_left / jump_duration
	sprite.offset = Vector2(0,4 * jump_height * temp * ( temp - 1))
	move_and_slide(motion)

func _on_Timer_timeout():
	timer.wait_time = jump_duration
	animationState.travel("Run")
	current_state = State.IDLE
