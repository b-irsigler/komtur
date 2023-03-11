extends KinematicBody2D


signal KomturAttack

enum State {IDLE, WALK, NEW_DIRECTION, INTERCEPT, RETURN, CHASE, ATTACK, COOLDOWN}

const max_state_changes_until_return_to_castle = 10
const INTERCEPT_RADIUS = 500

var sounds : Array
var random_number_generator = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2(rng_direction(), rng_direction())
var return_counter = 0
var player = null
var intercept_aim = Vector2(0,0)

onready var world = get_parent()
onready var start_position = Vector2(world.map_width/2, world.map_height/2 - 1)
onready var tilemap = $"../TileMap_Ground"
onready var state_change_timer = $StateChangeTimer
onready var cooldown_timer = $CooldownTimer
onready var attack_timer = $AttackTimer
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .7
onready var animation_speed = christine.default_animation_speed * .7
onready var audio = $KomturSFXPlayer
onready var sound_1 = preload("res://resources/assets/sfx/komtur_attack1.mp3")
onready var sound_2 = preload("res://resources/assets/sfx/komtur_attack2.mp3")
onready var sound_3 = preload("res://resources/assets/sfx/komtur_attack3.mp3")
onready var sound_4 = preload("res://resources/assets/sfx/komtur_attack4.mp3")
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var castle = $"../Castle"
onready var raycast = $RayCast2D


func _ready():
	randomize() 
	sounds = [ sound_1, sound_2, sound_3, sound_4 ] 
	audio.autoplay = false
	animation_tree.set("parameters/Walk/TimeScale/scale",animation_speed)
	animation_tree.set("parameters/Idle/TimeScale/scale",animation_speed)
	animation_tree.set("parameters/Chop/TimeScale/scale",animation_speed)
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	position = tilemap.map_to_world(start_position)


func _get_debug():
	return "Pos: %s, St: %s, is_colliding: %s" % [position.round(), State.keys()[current_state], raycast.is_colliding()]


func rng_direction():
	return random_number_generator.randf() - .5


func _physics_process(_delta):
	raycast.cast_to = 100 * motion.normalized()
	if raycast.is_colliding():
		if raycast.get_collider() != christine:
			current_state = State.NEW_DIRECTION
	match current_state:
		State.IDLE:
			animation_state.travel("Idle")
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
			state_change_timer.stop()
			if intercept_aim.length() == 0:
				var ChristineToCastle = christine.position - castle.position
				if  ChristineToCastle.length() < INTERCEPT_RADIUS:
					intercept_aim = christine.position
					motion = position.direction_to(christine.position)
				else:
					intercept_aim = ChristineToCastle.normalized()*INTERCEPT_RADIUS + castle.position
					motion = position.direction_to(intercept_aim)
				#start timer so if Komtur gets stuck, he will do something else after some time
				cooldown_timer.start(10)
			elif (position - intercept_aim).length() < 150:
				timerRandomState()
				intercept_aim = Vector2(0,0)
			else:
				walk(motion)
		State.RETURN:
			start_position = world.tilemap.map_to_world(world.start_position_komtur)
			motion = start_position - position
			walk(motion)
			# area which is considered as home
			if (start_position - position).length() < 2:
				state_change_timer.start()
				current_state = State.IDLE
		State.CHASE:
			#wrong state if play is null
			if player == null:
				timerRandomState()
			#break off chase after certain distance from castle
			elif (position - castle.position).length() > 1800:
				timerRandomState()
			#actual chase
			else:
				motion = position.direction_to(player.position)
				walk(motion)
		State.ATTACK:
			attack()
		State.COOLDOWN:
			pass


func walk(walk_motion):
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", walk_motion.normalized())
	animation_state.travel("Walk")
	walk_motion = walk_motion.normalized() * motion_speed
	move_and_slide(walk_motion)


func attack():
	_play_random_sound()
	attack_timer.start(1)
	animation_tree.set("parameters/Chop/BlendSpace2D/blend_position", motion.normalized())
	animation_state.travel("Chop")
	emit_signal("KomturAttack")
	state_change_timer.stop()
	current_state = State.COOLDOWN


func timerRandomState():
	current_state = random_number_generator.randi_range(0,3)
	state_change_timer.start(1)


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
		state_change_timer.stop()
		intercept_aim = Vector2(0,0)


func _on_KomturChaseArea_body_exited(body):
	if player != null and body.name == "Christine":
		player = null
		timerRandomState()


func _on_KomturAttackArea_body_entered(body):
	if body.name == "Christine":
		current_state = State.ATTACK
		christine.default_motion_speed /= 2


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


func _on_attack_timer_timeout():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", motion.normalized())
	animation_state.travel("Idle")
	cooldown_timer.wait_time = 5
	cooldown_timer.start()
	christine.default_motion_speed *= 2

