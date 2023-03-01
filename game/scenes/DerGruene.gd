extends KinematicBody2D


signal conversation_started(active)

enum State {IDLE, WALK, NEW_DIRECTION, CONVERSATION, AFTER_CONVERSATION}

const TELEPORT_PROBABILITY = .015

var random_number_generator = RandomNumberGenerator.new()
var current_state = State.IDLE
var motion = Vector2.ZERO
var direction = Vector2(rng_direction(), rng_direction()).normalized()
var start_position

onready var world = get_parent()
onready var tilemap = $"../TileMap_Ground"
onready var castle = $"../Castle"
onready var animation_tree = $AnimationTree
onready var state_change_timer = $StateChangeTimer
onready var after_conversation_timer = $AfterConversationTimer
onready var conversation_area = $ConversationArea
onready var animation_state = animation_tree.get("parameters/playback")
onready var christine = $"../Christine"
onready var motion_speed = christine.default_motion_speed * .30
onready var raycast = $RayCast2D
onready var teleport_animation = $GrueneTeleportAnimation
onready var fx_tween = $FxTween
onready var sprite = $Sprite
onready var speech = $GrueneSpeechAudioPlayer

func _ready():
	state_change_timer.connect("timeout", self, "_on_StateChangeTimer_timeout")
	after_conversation_timer.connect("timeout", self, "_on_AfterConversationTimer_timeout")
	to_start_position()


func _get_debug():
	return "Pos: %s, St: %s" % [position.round(), State.keys()[current_state]]


func _physics_process(_delta):
	motion = motion_speed * direction
	
	raycast.cast_to = 100 * motion.normalized()
	if raycast.is_colliding():
		if raycast.get_collider() != christine:
			current_state = State.NEW_DIRECTION
			
	if conversation_area.overlaps_body(christine) and current_state != State.AFTER_CONVERSATION:
		current_state = State.CONVERSATION
	
	match current_state:
		State.IDLE:
			animation_state.travel("Idle")
		State.WALK:
			walk()
		State.NEW_DIRECTION:
			direction = Vector2(rng_direction(), rng_direction()).normalized()
			current_state = State.WALK
		State.CONVERSATION:
			conversation()
		State.AFTER_CONVERSATION:
			pass


func rng_direction():
	return random_number_generator.randf() - .5


func walk():
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/Run/blend_position", direction)
	animation_state.travel("Run")
	move_and_slide(motion)


func teleport():
	if randf() < TELEPORT_PROBABILITY:
		var vec = christine.position - position
		var half_size = get_viewport().size * 0.5
		var clamped_vec = Vector2 (
				clamp(vec.x, -half_size.x, half_size.x),
				clamp(vec.y, -half_size.y, half_size.y)
			)
		if clamped_vec != vec and not castle.is_character_close_to_castle(position):
			position = christine.position + 2 * christine.motion


func conversation():
	emit_signal("conversation_started", true)
	if not speech.playing:
		speech.play()
	state_change_timer.stop()
	direction = (christine.position - position).normalized()
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_state.travel("Idle")


func to_start_position():
	var is_close_to_castle = true
	while is_close_to_castle:
		randomize()
		start_position = Vector2(rand_range(0, world.map_width), rand_range(0, world.map_height))
		is_close_to_castle = castle.is_close_to_castle(start_position)
		
	position = tilemap.map_to_world(start_position)
	#TESTING
	position = tilemap.map_to_world(christine.start_position+Vector2(0,4))


func _on_StateChangeTimer_timeout():
	state_change_timer.wait_time = 1
	teleport()
	var state_array = [State.IDLE, State.WALK, State.NEW_DIRECTION]
	state_array.shuffle()
	current_state = state_array[0]


func _on_AfterConversationTimer_timeout():
	position = Vector2(-20000, 0)
	teleport_animation.stop()
	teleport_animation.set_frame(0)
	sprite.scale = Vector2(1.0,1.0)
	state_change_timer.start()


func _on_Christine_deal_accepted():
	deal_finished()


func _on_Christine_deal_denied():
	deal_finished()


func deal_finished():
	speech.stop()
	$GrueneLaughSFXPlayer.play()
	emit_signal("conversation_started", false)
	fx_tween.interpolate_property(sprite, "scale", self.get_scale(), Vector2(0, 0), 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN, 0.5)
	fx_tween.start()
	teleport_animation.play()
	after_conversation_timer.start(2)
	current_state = State.AFTER_CONVERSATION


func _on_Gui_new_game():
	to_start_position()


func _on_ConversationArea_body_exited(body):
	if body.name == "Christine":
		current_state = State.IDLE
		state_change_timer.start()
		emit_signal("conversation_started", false)
