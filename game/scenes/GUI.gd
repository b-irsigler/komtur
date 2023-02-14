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
		popup.show_popup("Versprecht ihr ein ungetauftes Kind fuer ein Dutzend Buchen? (y/n)", 12.0)


func _on_Christine_deal_accepted():
	popup.visible = false
