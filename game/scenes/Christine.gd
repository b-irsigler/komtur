extends KinematicBody2D


signal beech_inventory_exceeded
signal deal_accepted
signal deal_denied
signal beech_chopped
signal beeches_submitted(beech_inventory)
signal spinne_has_killed

enum State {IDLE, WALK, RUN, JUMP, CHOP}

const RUN_MULT = 10

var running = false
var jump_height = 40
var jump_duration = 1
var motion = Vector2()
var direction = Vector2()
var default_motion_speed = 300
var current_motion_speed = default_motion_speed
var default_animation_speed = 1.2
var current_animation_speed = default_animation_speed
var is_deal_offered = false
var current_state = State.IDLE
var life = 10
var komtur_debuff_time = 3
var debuffed_speed = default_motion_speed / 2
var is_slowed = false

onready var world = get_parent().get_parent()
onready var start_position = Vector2(world.map_width/2 - 3, world.map_height/2 + 3)
onready var tilemap = $"../TileMap_Ground"
onready var chop_area = $ChopArea
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var der_gruene = $"%DerGruene"
onready var chapel = $"../Chapel"
onready var castle = $"../Castle"
onready var speech_audio = $ChristineSpeechPlayer
onready var debuff_timer = $DebuffTimer


func _get_debug():
	return "Pos: %s, St: %s, is_on_berhegen: %s, Life: %s" % [position.round(), 
		State.keys()[current_state], castle.is_on_berhegen(position,1000), life]


func _ready():
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
					body.set_outline(true)

	if is_deal_offered:
		if Input.is_action_just_pressed("yes"):
			der_gruene.start_deal_cooldown()
			is_deal_offered = false
			speech_audio.play_random_yesdeal()
			yield(speech_audio, "finished")
			Global.beech_count += 12
			emit_signal("deal_accepted")
		if Input.is_action_just_pressed("no"):
			der_gruene.start_deal_cooldown()
			is_deal_offered = false
			speech_audio.play_random_nodeal()
			yield(speech_audio, "finished")
			emit_signal("deal_denied")
		
	match current_state:
		State.IDLE:
			idle()
		State.WALK:
			if running:
				motion *= RUN_MULT
			walk()
		State.CHOP:
			chop()


func idle():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
	animation_state.travel("Idle")


func walk():
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
	animation_state.travel("Walk")
	move_and_slide(motion)


func chop():
	animation_tree.set("parameters/Chop/BlendSpace2D/blend_position", direction)
	animation_state.travel("Chop")

	#This area is for collision layer/mask 2, the same as the one for beeches
	for body in chop_area.get_overlapping_bodies():
		if Global.beech_inventory >= 5:
			emit_signal("beech_inventory_exceeded")
			$DigSFXPlayer.stop()
			speech_audio.play_random_cantcarry()
		elif not body.is_chopped:
			if body.chop():
				execute_beech_chop()


func _on_IntAreaCastle_body_entered(body):
	if body.name == "Castle" and Global.beech_inventory > 0:
		emit_signal("beeches_submitted", Global.beech_inventory)
		Global.beech_count += Global.beech_inventory
		Global.beech_inventory = 0
		


func execute_beech_chop():
	Global.beech_inventory += 1
	emit_signal("beech_chopped")
	$DigSFXPlayer.stop()
	$TreeFallingSFXPlayer.play()


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
		
	if is_slowed:
		current_animation_speed = .5 * default_animation_speed * (1 - .05 * Global.beech_inventory)
		current_motion_speed = .5 * default_motion_speed * (1 - .05 * Global.beech_inventory)
	else:
		current_animation_speed = default_animation_speed * (1 - .05 * Global.beech_inventory)
		current_motion_speed = default_motion_speed * (1 - .05 * Global.beech_inventory)


func _on_DerGruene_conversation_started(active):
	is_deal_offered = active


func _on_Spinne_has_attacked(damage, attack_direction):
	if life > 0:
		life -= damage
		$BloodParticles.direction = attack_direction
		$BloodParticles.emitting = true
	if life <=0:
		Global.blur._fade_and_deblur()
		yield(get_tree().create_timer(0.3), "timeout")
		$DeathSFXPlayer.play()
		position = chapel.position + world.tilemap.map_to_world(Vector2(0,1.5))
		Global.beech_inventory = 0
		emit_signal("spinne_has_killed")
		life = 10
		
	Global.lifebar.update_health(life)


func _on_ChopArea_body_entered(body):
	body.is_selected = true
	body.set_outline(true)


func _on_ChopArea_body_exited(body):
	body.is_selected = false
	body.set_outline(false)


func _on_komtur_has_attacked():
	debuff_timer.start(komtur_debuff_time)
	is_slowed = true


func _on_DebuffTimer_timeout():
	is_slowed = false
