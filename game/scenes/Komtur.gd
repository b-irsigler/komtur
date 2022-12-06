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

enum State {IDLE, WALK, NEW_DIRECTION, INTERCEPT, RETURN, CHASE, ATTACK, COOLDOWN}
var rng = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null
var intercept_aim = Vector2(0,0)
var CASTLE_POS = Vector2(0,0)
var INTERCEPT_RADIUS = 1500

func _ready():
	randomize() 
	sounds = [ sound_1, sound_2, sound_3, sound_4 ] 
	audio.autoplay = false
	animationTree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animationTree.set("parameters/Chop/TimeScale/scale",animation_speed)
	#CASTLE_POS = world.tilemap.map_to_world(world.start_position_castle)

func _get_debug():
	return "Pos: %s, St: %s, Aim: %s" % [position.round(), State.keys()[current_state], intercept_aim.round()]

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
		State.INTERCEPT:
			#walk towards Christines position if inside a radius a around castle
			#The intersection of radius a and the line connecting christine and castle
			#balance timer state change to 5s or more
			#result: Christine staying still will result in Komtur finding her
			timerStateChange.stop()
			if intercept_aim.length() == 0:
				var ChristineToCastle = christine.position - world.tilemap.map_to_world(world.start_position_castle)
				if  ChristineToCastle.length() < INTERCEPT_RADIUS:
					intercept_aim = christine.position
					motion = position.direction_to(christine.position)
				else:
					intercept_aim = ChristineToCastle.normalized()*INTERCEPT_RADIUS + world.tilemap.map_to_world(world.start_position_castle)
					motion = position.direction_to(intercept_aim)
				#start timer so if Komtur gets stuck, he will do something else after some time
				timerCooldown.start(10)
			elif (position - intercept_aim).length() < 150:
				timerRandomState()
				intercept_aim = Vector2(0,0)
			else:
				walk(motion)
		State.RETURN:
			var start_position = world.tilemap.map_to_world(world.start_position_komtur)
			motion = start_position - position
			walk(motion)
			# area which is considered as home
			if (start_position - position).length() < 2:
				timerStateChange.start()
				current_state = State.IDLE
		State.CHASE:
			#wrong state if play is null
			if player == null:
				timerRandomState()
			#break off chase after certain distance from castle
			elif (position - world.tilemap.map_to_world(world.start_position_castle)).length() > 1800:
				timerRandomState()
			#actual chase
			else:
				motion = position.direction_to(player.position)
				walk(motion)
		State.ATTACK:
			attack()
		State.COOLDOWN:
			pass
				
func walk(motionvec):
	animationTree.set("parameters/Walk/BlendSpace2D/blend_position", motionvec.normalized())
	animationState.travel("Walk")
	motionvec = motionvec.normalized() * motion_speed
	move_and_slide(motionvec)
	
func attack():
	_play_random_sound()
	timerAttack.start(.6)
	animationTree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Chop")
	emit_signal("KomturAttack")
	timerStateChange.stop()
	current_state = State.COOLDOWN
	
func timerRandomState():
	current_state = rng.randi_range(0,3)
	timerStateChange.start(1)
	
func _on_TimerStateChange_timeout():
	if current_state == State.COOLDOWN:
		pass
	else:
		timerRandomState()
	#pass # Replace with function body.

func _on_KomturChaseArea_body_entered(body):
	if player == null and body.name == "Christine":
		player = body
		current_state = State.CHASE
		timerStateChange.stop()
		intercept_aim = Vector2(0,0)

func _on_KomturChaseArea_body_exited(body):
	if player != null and body.name == "Christine":
		player = null
		timerRandomState()

func _on_KomturAttackArea_body_entered(body):
	if body.name == "Christine":
		current_state = State.ATTACK

func _on_KomturAttackArea_body_exited(body):
	pass
	#if body.name == "Christine" and current_state != State.COOLDOWN:
	#	current_state = State.CHASE
	
func _play_random_sound():
	var sound_index = randi() % 4 
	var sound = sounds[sound_index] 
	sound.loop = false
	audio.stream = sound 
	audio.play() 

func _on_KomturSFXPlayer_finished():
	audio.stop()

func _on_TimerCooldown_timeout():
	if current_state == State.COOLDOWN:
		current_state = State.CHASE
	elif player == null:
		timerRandomState()

func _on_TimerAttack_timeout():
	animationTree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animationState.travel("Idle")
	timerCooldown.wait_time = 5
	timerCooldown.start()



