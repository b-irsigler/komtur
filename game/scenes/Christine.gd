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

onready var world = get_parent()
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
onready var beech = $"../Beech"


func _get_debug():
	return "Pos: %s, St: %s, is_on_berhegen: %s" % [position.round(), 
		State.keys()[current_state], castle.is_on_berhegen(position,1000)]


func _ready():
	jump_timer.connect("timeout",self,"_on_jump_timer_timeout")
	position = tilemap.map_to_world(start_position)


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
	print("beech counters", beech_count, ",", beech_count_increment)
	var alameda_positions = []
	for i in range(10):
		alameda_positions += [Vector2(i,i), Vector2(i+1,i)]
		alameda_positions += [Vector2(5-i,5+i), Vector2(5-i+1,5+i)]
		alameda_positions += [Vector2(10+i,10+i), Vector2(10+i+1,10+i)]
		alameda_positions += [Vector2(15-i,15+i), Vector2(15-i+1,15+i)]
		alameda_positions += [Vector2(20+i,20+i), Vector2(20+i+1,20+i)]
	for beech_position in alameda_positions:
		var instance = preload("res://scenes/tree_beech.tscn").instance()
		instance.position = tilemap.map_to_world(castle.start_position 
			+ beech_position)
		world.add_child(instance)

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


func _on_Spinne_has_attacked(damage):
	if life <= 0:
		$DeathSFXPlayer.play()
		position = chapel.position + world.tilemap.map_to_world(Vector2(0,1.5))
		update_beech_counters(-beech_inventory, 0)
		life = 10
	else:
		life -= damage

