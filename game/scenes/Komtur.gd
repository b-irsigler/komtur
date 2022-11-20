extends KinematicBody2D

var motion_speed = 160 # Pixels/second.
const RUN_MULT = 10
const max_return_counter = 10

signal KomturAttack

onready var world = get_parent()
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var timerReturn = $TimerReturn
onready var timerCooldown = $TimerCooldown
onready var animationState = animationTree.get("parameters/playback")

onready var audio = $KomturSFXPlayer

onready var sound_1 = preload("res://resources/assets/sfx/komtur_attack1.mp3")
onready var sound_2 = preload("res://resources/assets/sfx/komtur_attack2.mp3")
onready var sound_3 = preload("res://resources/assets/sfx/komtur_attack3.mp3")
onready var sound_4 = preload("res://resources/assets/sfx/komtur_attack4.mp3")

var sounds : Array

func _ready():
	# randomize to make sure our random numbers are always random
	randomize() 
	# an array of all sounds
	sounds = [ sound_1, sound_2, sound_3, sound_4 ] 
	audio.autoplay = false
	# play a random sound 

enum State {IDLE, WALK, NEW_DIRECTION, RETURN, CHASE, ATTACK, COOLDOWN}
var rng = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null

func rng_direction():
	return rng.randf() - .5

func _physics_process(_delta):
	motion_speed = get_parent().get_node("Christine").motion_speed
	match current_state:
		State.IDLE:
			animationState.travel("Idle")
		State.WALK:
			walk(motion)
		State.NEW_DIRECTION:
			motion = Vector2(rng_direction(), rng_direction())
			current_state = State.WALK
		State.RETURN:
			var start_position = world.tilemap.map_to_world(world.start_position_komtur)
			motion = start_position - position
			walk(motion)
			# area which is considered as home
			if (start_position - position).length() < 2:
				timerReturn.start()
				current_state = State.IDLE
		State.CHASE:
			if player == null:
				timerReturn.wait_time = 1
				current_state = rng.randi_range(0,2)
			else:
				motion = position.direction_to(player.position)
				walk(motion)
		State.ATTACK:
			_play_random_sound()
			animationTree.set("parameters/Chop/blend_position", motion.normalized())
			animationState.travel("Chop")
			emit_signal("KomturAttack")
			current_state = State.COOLDOWN
			timerCooldown.wait_time = 30
			timerCooldown.start()
		State.COOLDOWN:
			animationTree.set("parameters/Idle/blend_position", motion.normalized())
			animationState.travel("Idle")
				
func walk(motion):
	animationTree.set("parameters/Idle/blend_position", motion.normalized())
	animationTree.set("parameters/Run/blend_position", motion.normalized())
	animationState.travel("Run")
	motion = motion.normalized() * motion_speed
	move_and_slide(motion)

func _on_TimerReturn_timeout():
	return_counter += 1
	if return_counter == max_return_counter:
		timerReturn.stop()
		current_state = State.RETURN
		return_counter = 0
	else:
		timerReturn.wait_time = 1
		# supposedly, there is a function randi_range(from,to), but it somehow doesn't exist
		# It's a function of the random number generator object :D 
		current_state = rng.randi_range(0,2)


func _on_KomturChaseArea_body_entered(body):
	if player == null and body.name == "Christine":
		player = body
		current_state = State.CHASE
		timerReturn.stop()

func _on_KomturChaseArea_body_exited(body):
	if player != null and body.name == "Christine":
		player = null
		timerReturn.wait_time = 1
		current_state = rng.randi_range(0,2)

func _on_KomturAttackArea_body_entered(body):
	if body.name == "Christine":
		current_state = State.ATTACK

func _on_KomturAttackArea_body_exited(body):
	if body.name == "Christine" and current_state != State.COOLDOWN:
		current_state = State.CHASE
	
func _play_random_sound():
	# get a random number between 0 and 3
	var sound_index = randi() % 4 
	# get a sound with random index
	var sound = sounds[sound_index] 
	# set the sound to the audio stream player
	sound.loop = false
	audio.stream = sound 
	# play the sound
	audio.play() 

func _on_KomturSFXPlayer_finished():
	audio.stop()
