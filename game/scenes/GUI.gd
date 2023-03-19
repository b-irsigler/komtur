extends CanvasLayer


signal new_game
enum State {INGAME, INTRO, TUTORIAL, MENU, OVER}

var total_time_seconds = 600
var total_time_seconds_per_30_days = total_time_seconds / 30
var current_gui_state setget _set_gui_state
var last_gui_state

onready var game_timer = $IngameGUI/GameTimer
onready var label_beech = $IngameGUI/LabelBeech
onready var label_time = $IngameGUI/LabelTime
onready var castle =$"../Castle"
onready var popup = $IngameGUI/Popup
onready var menu = $Menu
onready var intro_screen = $IntroScreen
onready var tutorial_screen = $TutorialScreen
onready var tutorial_button_back = $TutorialScreen/ButtonBack
onready var ingame_gui = $IngameGUI
onready var camera = $"../Christine/Camera2D"
onready var direction_indicator = $IngameGUI/DirectionIndicator
onready var lifebar = $IngameGUI/LifeBar


func _ready():
	Global.gui = self
	Global.lifebar = lifebar
	
	menu.connect("new_game",self,"_on_Menu_new_game")
	menu.menu_debug.connect("toggled", self, "_on_DebugToggle")
	menu.menu_tutorial.connect("pressed", self, "_on_button_tutorial_pressed")
	menu.menu_resume.connect("pressed", self, "_on_Menu_resume")
	intro_screen.connect("text_intro_button_pressed", self, "_on_intro_button_pressed")
	intro_screen.button_tutorial.connect("pressed", self, "_on_button_tutorial_pressed") 
	tutorial_button_back.connect("pressed", self, "_on_tutorial_back_pressed")
	
	total_time_seconds_per_30_days = total_time_seconds / 30
	label_time.text = "noch %s Tage" % timer_to_days(game_timer.time_left)
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [0, 0]
	
	_set_gui_state(State.INTRO)
	ingame_gui.visible = false
	$DebugOverlay.visible = false
	menu.visible = false
	intro_screen._start()
	
	menu._game_timer = game_timer.get_path()


func _physics_process(_delta):
	if current_gui_state != State.INGAME:
		if current_gui_state == State.INTRO and Input.is_action_pressed("chop"):
			intro_screen.interrupt_text()
	else:
		label_time.text = "noch %s Tage" % timer_to_days(game_timer.time_left)
		if timer_to_days(game_timer.time_left) == 0:
			menu.game_finished(false)
		update_castle_indicator()


#Handles UI inputs
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if current_gui_state == State.INGAME:
			menu.set_is_paused(true)
			menu.menu_resume.visible = true
			menu.menu_reason.text = "Spiel Pausiert"
			game_timer.paused = true
			_set_gui_state(State.MENU)
		elif current_gui_state == State.MENU:
			menu.set_is_paused(false)
			game_timer.paused = false
			_set_gui_state(State.INGAME)
		elif current_gui_state == State.INTRO:
			intro_screen.interrupt_text()
	if event.is_action_pressed("ui_accept"):
		if current_gui_state == State.INTRO:
			intro_screen.interrupt_text()


func timer_to_days(time: float = 0):
	return round(time / total_time_seconds_per_30_days)


func update_castle_indicator():
	direction_indicator.update_indicator(castle.position)



func _on_Menu_new_game():
	emit_signal("new_game")
	game_timer.start(total_time_seconds)


func _on_Menu_resume():
	menu.set_is_paused(false)
	game_timer.paused = false
	_set_gui_state(State.INGAME)


func _on_DebugToggle(is_checked: bool):
	$DebugOverlay.visible = is_checked


func _on_intro_button_pressed():
	ingame_gui.visible = true
	$DebugOverlay.visible = true
	game_timer.start(total_time_seconds)
	_set_gui_state(State.INGAME)


func _on_button_tutorial_pressed():
	tutorial_screen.visible = true
	$DebugOverlay.visible = false
	ingame_gui.visible = false
	_set_gui_state(State.TUTORIAL)
	match last_gui_state:
		State.MENU:
			menu.visible = false
		State.INTRO:
			intro_screen.visible = false
		_:
			assert(false, "Illegal state transition to Tutorial Screen")


func _on_tutorial_back_pressed():
	tutorial_screen.visible = false
	match last_gui_state:
		State.MENU:
			menu.visible = true
			_set_gui_state(State.MENU)
			$DebugOverlay.visible = menu.menu_debug.pressed
			ingame_gui.visible = true
		State.INTRO:
			intro_screen.visible = true
			_set_gui_state(State.INTRO)
		_:
			assert(false, "Illegal state transition from Tutorial Screen")


func _on_Christine_beech_chopped(inventory, count):
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [count, inventory]
	if count >= 100:
		menu.game_finished(true)
		current_gui_state = State.OVER


func _on_Christine_beech_inventory_exceeded():
	popup.show_popup("Ihr seid voll mit Buchen! Ladet sie am Schloss ab um den Komtur zu besänftigen!")
	popup.visible = true


func _on_DerGruene_conversation_started(active):
	popup.visible = active
	if active:
		popup.show_popup("Versprecht ihr ein ungetauftes Kind für ein Dutzend Buchen? (y/n)", 12.0)


func _on_Christine_deal_accepted():
	popup.visible = false


func _set_gui_state(new_gui_state):
	last_gui_state = current_gui_state
	current_gui_state = new_gui_state
