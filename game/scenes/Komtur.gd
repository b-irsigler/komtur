extends KinematicBody2D

const max_return_counter = 10

signal KomturAttack

onready var world = get_parent()
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var timerStateChange = $TimerStateChange
onready var timerCooldown = $TimerCooldown
onready var timerAttack = $TimerAttack
onready var animationState = animationTree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .85
onready var animation_speed = christine.default_animation_speed * .85

onready var audio = $KomturSFXPlayer

onready var sound_1 = preload("res://resources/assets/sfx/komtur_attack1.mp3")
onready var sound_2 = preload("res://resources/assets/sfx/komtur_attack2.mp3")
onready var sound_3 = preload("res://resources/assets/sfx/komtur_attack3.mp3")
onready var sound_4 = preload("res://resources/assets/sfx/komtur_attack4.mp3")

var sounds : Array

func _ready():
	randomize() 
	sounds = [ sound_1, sound_2, sound_3, sound_4 ] 
	audio.autoplay = false
	animationTree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Chop/TimeScale/scale",animation_speed)

enum State {IDLE, WALK, NEW_DIRECTION, RETURN, CHASE, ATTACK, COOLDOWN}
var rng = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null

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
		State.RETURN:
			var start_position = world.tilemap.map_to_world(world.start_position_komtur)
			motion = start_position - position
			walk(motion)
			# area which is considered as home
			if (start_position - position).length() < 2:
				timerStateChange.start()
				current_state = State.IDLE
		State.CHASE:
			if player == null:
				timerStateChange.wait_time = 1
				current_state = rng.randi_range(0,2)
			else:
				motion = position.direction_to(player.position)
				walk(motion)
		State.ATTACK:
			attack()
		State.COOLDOWN:
			pass
				
func walk(motion):
	animationTree.set("parameters/Walk/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Walk")
	motion = motion.normalized() * motion_speed
	move_and_slide(motion)
	
func attack():
	_play_random_sound()
	
	timerAttack.start(.6)
	animationTree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Chop")
	
func timerRandomState():
	current_state = rng.randi_range(0,2)
	timerStateChange.start(1)

func _on_TimerReturn_timeout():
	return_counter += 1
	if current_state == State.COOLDOWN:
		pass
	elif return_counter == max_return_counter:
		timerStateChange.stop()
		current_state = State.RETURN
		return_counter = 0
	else:
		timerRandomState()

func _on_KomturChaseArea_body_entered(body):
	if player == null and body.name == "Christine":
		player = body
		current_state = State.CHASE
		timerStateChange.stop()

func _on_KomturChaseArea_body_exited(body):
	if player != null and body.name == "Christine":
		player = null
		timerRandomState()

func _on_KomturAttackArea_body_entered(body):
	if body.name == "Christine":
		current_state = State.ATTACK

func _on_KomturAttackArea_body_exited(body):
	if body.name == "Christine" and current_state != State.COOLDOWN:
		current_state = State.CHASE
	
func _play_random_sound():
	var sound_index = randi() % 4 
	var sound = sounds[sound_index] 
	sound.loop = false
	audio.stream = sound 
	audio.play() 

func _on_KomturSFXPlayer_finished():
	audio.stop()

func _on_TimerCooldown_timeout():
	if current_state != State.COOLDOWN:
		pass
	if player == null:
		timerRandomState()
	else:
		current_state = State.CHASE

func _on_TimerAttack_timeout():
	emit_signal("KomturAttack")
	animationTree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Idle")
	current_state = State.COOLDOWN
	timerCooldown.wait_time = 5
	timerCooldown.start()
	timerStateChange.stop()
