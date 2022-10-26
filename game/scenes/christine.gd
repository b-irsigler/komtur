extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
const RUN_MULT = 10

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $Sprite
onready var timer = $Timer
onready var area = $Area2D
onready var label = $RichTextLabel
var running = false
var jump_height = 40
var jump_duration = 1
var motion = Vector2()
var direction = Vector2()
var beech_count = 0

enum State {IDLE, WALK, RUN, JUMP, CHOP}
var current_state = State.IDLE

var dynamic_font = DynamicFont.new()

func _ready():
	dynamic_font.font_data = load("res://resources/fonts/lohengrin.regular.ttf")
	dynamic_font.size = 32
	label.add_color_override("default_color", Color(1,.84,0,1))
	label.add_font_override("normal_font", dynamic_font)

func _physics_process(_delta):
	if beech_count < 10:
		label.text = "Buchen: %s" % beech_count
	else:
		dynamic_font.size = 128
		label.text = "Gewonnen!"
		label.rect_position = Vector2(0,0) - label.rect_size/2
	
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= float(2)
	
	if motion == Vector2.ZERO:
		current_state = State.IDLE
	elif current_state != State.JUMP:
		direction = motion.normalized()
		current_state = State.WALK
		
	motion = direction * MOTION_SPEED
	
	if Input.is_action_just_pressed("run"):
		running = not running
	if Input.is_action_just_pressed("jump") and current_state != State.JUMP:
		current_state = State.JUMP
		timer.start()
	if Input.is_action_pressed("chop"):
		current_state = State.CHOP
		
	match current_state:
		State.IDLE:
			idle()
		State.WALK:
			if running:
				motion *= RUN_MULT
			walk(motion)
		State.JUMP:
			jump()
		State.CHOP:
			chop()
			
func idle():
	animationTree.set("parameters/Idle/blend_position", direction)
	animationState.travel("Idle")
	
func walk(motion):
	animationTree.set("parameters/Run/blend_position", direction)
	animationState.travel("Run")
	move_and_slide(motion)

func jump():
	animationState.travel("Stop")
	var temp = timer.time_left / jump_duration
	sprite.offset = Vector2(0,4 * jump_height * temp * ( temp - 1))
	move_and_slide(motion)
	
func chop():
	animationTree.set("parameters/Chop/blend_position", direction)
	animationState.travel("Chop")

	#This area is for collision layer/mask 2, the same as the one for beeches
	for body in area.get_overlapping_bodies():
		if body:
			beech_count += 1
		body.queue_free()
		

func _on_Timer_timeout():
	timer.wait_time = jump_duration
	animationState.travel("Run")
	current_state = State.IDLE
