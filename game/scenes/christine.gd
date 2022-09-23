extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
const RUN_MULT = 10

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $Sprite
onready var timer  = $Timer
var jumping = false
var jump_height = 40
var jump_duration = 1

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= float(2)
	
	if jumping:
		animationState.travel("stop")
		sprite.offset = Vector2(0,jump(timer.time_left))

	if motion != Vector2.ZERO:
		if not jumping:
			animationTree.set("parameters/Idle/blend_position", motion.normalized())
			animationTree.set("parameters/Run/blend_position", motion.normalized())
			animationState.travel("Run")
		if Input.is_action_pressed("run"):
			jumping = true
			timer.start()
			animationState.travel("stop")
			motion = motion.normalized() * MOTION_SPEED #* RUN_MULT
		else:
			motion = motion.normalized() * MOTION_SPEED
	if motion == Vector2.ZERO:
		animationState.travel("Idle")
		motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	move_and_slide(motion)

func jump(time):
	var temp = time / jump_duration
	return 4 * jump_height * temp * ( temp - 1)

func _on_Timer_timeout():
	timer.wait_time = jump_duration
	jumping = false
	animationState.travel("Run")
