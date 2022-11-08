extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
const RUN_MULT = 10

signal BeechChopped(inventory, count)
signal BeechesExceeded

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $Sprite
onready var timer = $Timer
onready var dayTimer = $Timer2
onready var area = $Area2D
onready var beechCounterLabel = $BeechCounterLabel
onready var daysLeftLabel = $DaysLeftLabel
var running = false
var jump_height = 40
var jump_duration = 1
var motion = Vector2()
var direction = Vector2()
var beech_count = 0
var beech_inventory = 0

enum State {IDLE, WALK, RUN, JUMP, CHOP}
var current_state = State.IDLE

var dynamic_font = DynamicFont.new()

func _ready():
	dynamic_font.font_data = load("res://resources/fonts/lohengrin.regular.ttf")
	dynamic_font.size = 32
	beechCounterLabel.add_color_override("default_color", Color(1,.84,0,1))
	beechCounterLabel.add_font_override("normal_font", dynamic_font)
	daysLeftLabel.add_color_override("default_color", Color(1,.84,0,1))
	daysLeftLabel.add_font_override("normal_font", dynamic_font)

func _physics_process(_delta):
	daysLeftLabel.text = "noch %s Tage" % round(dayTimer.time_left / 60)
	if beech_count < 10:
		beechCounterLabel.text = "Buchen: %s" % beech_count
	else:
		daysLeftLabel.text = ""
		dynamic_font.size = 128
		beechCounterLabel.text = "Gewonnen!"
		beechCounterLabel.rect_position = Vector2(0,0) - beechCounterLabel.rect_size/2
	
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
			if beech_inventory > 4:
				emit_signal("BeechesExceeded")
			else:
				beech_inventory += 1
				emit_signal("BeechChopped", beech_inventory, beech_count)
				body.queue_free()
		

func _on_Timer_timeout():
	timer.wait_time = jump_duration
	animationState.travel("Run")
	current_state = State.IDLE

func _on_IntAreaCastle_body_entered(body):
	if body.name == "Castle" and beech_inventory > 0:
		beech_count += beech_inventory
		beech_inventory = 0
		emit_signal("BeechChopped", beech_inventory, beech_count)
