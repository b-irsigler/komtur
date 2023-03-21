extends KinematicBody2D


signal beech_chopped(inventory, count)
signal beech_inventory_exceeded
signal deal_accepted
signal deal_denied

enum State {IDLE, WALK, RUN, JUMP, CHOP}

const RUN_MULT = 10

var running = false
var jump_height = 40
var jump_duration = 1
var motion = Vector2()
var direction = Vector2()
var beech_count = 0
var beech_inventory = 0
var default_motion_speed = 300
var current_motion_speed = default_motion_speed
var default_animation_speed = 1.5
var current_animation_speed = default_animation_speed
var is_deal_offered = false
var current_state = State.IDLE
var life = 10

onready var world = get_parent().get_parent()
onready var start_position = Vector2(world.map_width/2 - 3, world.map_height/2 + 3)
onready var tilemap = $"../TileMap_Ground"
onready var sprite = $Sprite
onready var jump_timer = $JumpTimer
onready var day_timer = $DayTimer
onready var chop_area = $ChopArea
onready var beech_counter_label = $BeechCounterLabel
onready var days_left_label = $DaysLeftLabel
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var chapel = $"../Chapel"
onready var castle = $"../Castle"


func _get_debug():
	return "Pos: %s, St: %s, is_on_berhegen: %s, Life: %s" % [position.round(), 
		State.keys()[current_state], castle.is_on_berhegen(position,1000), life]


func _ready():
	jump_timer.connect("timeout",self,"_on_jump_timer_timeout")
	position = tilemap.map_to_world(start_position)
	Global.christine = self
	Global.camera = $Camera2D


func _physics_process(_delta):
	update_speed()

	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= float(2)
	
	if motion == Vector2.ZERO:
		current_state = State.IDLE
	elif current_state != State.JUMP:
		direction = motion.normalized()
		current_state = State.WALK

	motion = direction * current_motion_speed
	
	if Input.is_action_just_pressed("run"):
		running = not running
	if Input.is_action_just_pressed("jump") and current_state != State.JUMP:
		current_state = State.JUMP
		jump_timer.start()
	if Input.is_action_pressed("chop"):
		if not $DigSFXPlayer.playing and chop_area.get_overlapping_bodies().size() > 0:
			$DigSFXPlayer.play()
		current_state = State.CHOP
	if Input.is_action_just_released("chop"):
		$DigSFXPlayer.stop()
		if chop_area.get_overlapping_bodies().size() > 0:
			for body in chop_area.get_overlapping_bodies():
				if body.is_being_chopped:
					body.is_being_chopped = false

	if is_deal_offered:
		if Input.is_action_just_pressed("yes"):
			emit_signal("deal_accepted")
			update_beech_counters(0, 12)
			is_deal_offered = false
		if Input.is_action_just_pressed("no"):
			emit_signal("deal_denied")
			is_deal_offered = false
		
	match current_state:
		State.IDLE:
			idle()
		State.WALK:
			if running:
				motion *= RUN_MULT
			walk()
		State.JUMP:
			jump()
		State.CHOP:
			chop()

	for body in chop_area.get_overlapping_bodies():
		body.is_selected = true
	

func idle():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
	animation_state.travel("Idle")


func walk():
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
	animation_state.travel("Walk")
	move_and_slide(motion)


func jump():
	animation_state.travel("Stop")
	var temp = jump_timer.time_left / jump_duration
	sprite.offset = Vector2(0,4 * jump_height * temp * ( temp - 1))
	move_and_slide(motion)


func chop():
	animation_tree.set("parameters/Chop/BlendSpace2D/blend_position", direction)
	animation_state.travel("Chop")

	#This area is for collision layer/mask 2, the same as the one for beeches
	for body in chop_area.get_overlapping_bodies():
		if beech_inventory >= 5:
			emit_signal("beech_inventory_exceeded")
			$DigSFXPlayer.stop()
		elif not body.is_chopped:
			if body.chop():
				update_beech_counters(1, 0)
				$DigSFXPlayer.stop()
				$TreeFallingSFXPlayer.play()


func update_beech_counters(beech_inventory_increment, beech_count_increment):
	beech_inventory += beech_inventory_increment
	beech_count += beech_count_increment
	emit_signal("beech_chopped", beech_inventory, beech_count)


func _on_jump_timer_timeout():
	jump_timer.wait_time = jump_duration
	animation_state.travel("Run")
	current_state = State.IDLE


func _on_IntAreaCastle_body_entered(body):
	if body.name == "Castle" and beech_inventory > 0:
		update_beech_counters(-beech_inventory, beech_inventory)


func update_speed():
	if Input.is_action_just_pressed("increase_animation_speed"):
		default_animation_speed += .1
	if Input.is_action_just_pressed("decrease_animation_speed"):
		default_animation_speed -= .1
	animation_tree.set("parameters/Walk/TimeScale/scale", default_animation_speed)
	animation_tree.set("parameters/Idle/TimeScale/scale", default_animation_speed)
	animation_tree.set("parameters/Chop/TimeScale/scale", default_animation_speed)
	
	if Input.is_action_just_pressed("increase_motion_speed"):
		default_motion_speed += 5
	if Input.is_action_just_pressed("decrease_motion_speed"):
		default_motion_speed -= 5
		
	current_animation_speed = default_animation_speed * (1 - .05 * beech_inventory)
	current_motion_speed = default_motion_speed * (1 - .05 * beech_inventory)


func _on_DerGruene_conversation_started(active):
	is_deal_offered = active


func _on_Spinne_has_attacked(damage, direction):
	if life > 0:
		life -= damage
		$BloodParticles.direction = direction
		$BloodParticles.emitting = true
	if life <=0:
		Global.blur._fade_and_deblur()
		yield(get_tree().create_timer(0.3), "timeout")
		$DeathSFXPlayer.play()
		position = chapel.position + world.tilemap.map_to_world(Vector2(0,1.5))
		update_beech_counters(-beech_inventory, 0)
		life = 10
		
	Global.lifebar.update_health(life)


func _on_ChopArea_body_exited(body):
	body.is_selected = false
