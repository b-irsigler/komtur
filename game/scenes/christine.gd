extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= float(2)
	
	if motion != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", motion.normalized())
		animationTree.set("parameters/Run/blend_position", motion.normalized())
		animationState.travel("Run")
		motion = motion.normalized() * MOTION_SPEED
		print(motion.normalized())
	if motion == Vector2.ZERO:
		animationState.travel("Idle")
		motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	move_and_slide(motion)
