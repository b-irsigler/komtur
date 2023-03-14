extends CanvasLayer


signal new_game

var total_time_seconds = 600
var total_time_seconds_per_30_days = total_time_seconds / 30

onready var game_timer = $GameTimer
onready var label_beech = $LabelBeech
onready var label_time = $LabelTime
onready var castle =$"../Castle"
onready var popup = $Popup
onready var menu = $Menu
onready var camera = $"../Christine/Camera2D"
onready var castle_indicator = $CastleIndicator


func _ready():
	menu.connect("new_game",self,"_on_Menu_new_game") 
	game_timer.start(total_time_seconds)
	total_time_seconds_per_30_days = total_time_seconds / 30
	label_time.text = "noch %s Tage" % timer_to_days(game_timer.time_left)
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [0, 0]


func _physics_process(_delta):
	label_time.text = "noch %s Tage" % timer_to_days(game_timer.time_left)
	if timer_to_days(game_timer.time_left) == 0:
		menu.game_finished(false)
	update_castle_indicator()


func timer_to_days(time: float = 0):
	return round(time / total_time_seconds_per_30_days)


func update_castle_indicator():
	var center = camera.get_camera_screen_center()
	var target = castle.position
	var displacement = target - center
	var margin = castle_indicator.rect_size * 0.5
	var half_size = get_viewport().size * 0.5
	var clamped_displacement = Vector2(
		clamp(displacement.x, -half_size.x, half_size.x - margin.x),
		clamp(displacement.y, -half_size.y, half_size.y - margin.y)
		)
	if clamped_displacement == displacement:
		castle_indicator.visible = false
	else:
		castle_indicator.visible = true
	castle_indicator.rect_position = clamped_displacement + half_size

func deal_accepted_from_dialog():
	print("deal akzeptiert aus dialog")
	emit_signal("deal_accepted_from_dialog", 0, 12)

func deal_denied_from_dialog():
	print("deal nope, eww! aus dialog")
	emit_signal("deal_denied_from_dialog")

func _on_Menu_new_game():
	print("_on_Menu_new_game GUI")
	emit_signal("new_game")
	game_timer.start(total_time_seconds)


func _on_Christine_beech_chopped(inventory, count):
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [count, inventory]
	if count >= 100:
		menu.game_finished(true)


func _on_Christine_beech_inventory_exceeded():
	popup.show_popup("Ihr seid voll mit Buchen! Ladet sie am Schloss ab um den Komtur zu besänftigen!")
	popup.visible = true


func _on_DerGruene_conversation_started(active):
	popup.visible = active
	if active:
		var dialogue_resource = preload("res://resources/dialog/Gruene_Offer.tres")
		show_dialogue_balloon("Gruene_Offer", dialogue_resource)
		#var dialogue_line = yield(DialogueManager.get_next_dialogue_line("Gruene_Offer", dialogue_resource), "_on_Christine_deal_accepted")
		#popup.show_popup("Versprecht ihr ein ungetauftes Kind fuer ein Dutzend Buchen? (y/n)", 12.0)


func _on_Christine_deal_accepted():
	popup.visible = false


func show_dialogue_balloon(title: String, local_resource: DialogueResource = null, extra_game_states: Array = []) -> void:
	var dialogue_line = yield(DialogueManager.get_next_dialogue_line(title, local_resource, extra_game_states), "completed")
	if dialogue_line != null:
		var balloon = preload("res://addons/dialogue_manager/komtur_dialog/komtur_balloon.tscn").instance()
		balloon.dialogue_line = dialogue_line
		get_tree().current_scene.add_child(balloon)
		show_dialogue_balloon(yield(balloon, "actioned"), local_resource, extra_game_states)
