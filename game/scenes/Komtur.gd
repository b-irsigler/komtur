extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
const RUN_MULT = 10

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
var time = 0
var rng = RandomNumberGenerator.new()
var motion = Vector2()

func _physics_process(_delta):
	time += _delta
	#print(time)
	
	if time > 2.0 and time < 3:
		motion.x = rng.randf() - .5
		motion.y = rng.randf() - .5
		time = 3
		
	if time >= 4 and time < 5:
		motion = Vector2.ZERO
		time = 5
		
	if time > 5:
		time = 0

	if motion != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", motion.normalized())
		animationTree.set("parameters/Run/blend_position", motion.normalized())
		animationState.travel("Run")
		motion = motion.normalized() * MOTION_SPEED
	if motion == Vector2.ZERO:
		animationState.travel("Idle")
		motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	move_and_slide(motion)
