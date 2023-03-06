extends CanvasLayer


signal new_game
enum State {INGAME, INTRO, MENU}

var total_time_seconds = 600
var total_time_seconds_per_30_days = total_time_seconds / 30
var current_gui_state

onready var game_timer = $IngameGUI/GameTimer
onready var label_beech = $IngameGUI/LabelBeech
onready var label_time = $IngameGUI/LabelTime
onready var castle =$"../Castle"
onready var popup = $IngameGUI/Popup
onready var menu = $Menu
onready var intro_screen = $IntroScreen
onready var ingame_gui = $IngameGUI
onready var camera = $"../Christine/Camera2D"
onready var castle_indicator = $IngameGUI/CastleIndicator


func _ready():
	menu.connect("new_game",self,"_on_Menu_new_game")
	intro_screen.connect("text_intro_button_pressed", self, "_on_intro_button_pressed") 
	
	game_timer.start(total_time_seconds)
	total_time_seconds_per_30_days = total_time_seconds / 30
	label_time.text = "noch %s Tage" % timer_to_days(game_timer.time_left)
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [0, 0]
	
	current_gui_state = State.INTRO
	ingame_gui.visible = false
	intro_screen._start()


func _physics_process(_delta):
	label_time.text = "noch %s Tage" % timer_to_days(game_timer.time_left)
	if timer_to_days(game_timer.time_left) == 0:
		menu.game_finished(false)
	update_castle_indicator()


#Negates current is_paused state if Esc is pressed
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if current_gui_state == State.INGAME or current_gui_state == State.MENU:
			menu.set_is_paused(!menu.is_paused)
			menu.menu_resume.visible = true
			menu.menu_reason.text = "Spiel Pausiert"
		elif current_gui_state == State.INTRO:
			intro_screen.interrupt_text()


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
	#intro_screen._start()
	emit_signal("new_game")
	game_timer.start(total_time_seconds)


func _on_intro_button_pressed():
	ingame_gui.visible = true
	current_gui_state = State.INGAME


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
		popup.show_popup("Versprecht ihr ein ungetauftes Kind für ein Dutzend Buchen? (y/n)", 12.0)


func _on_Christine_deal_accepted():
	popup.visible = false
