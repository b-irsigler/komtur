extends CanvasLayer

signal NewGame
onready var dayTimer = $"30Tage"
onready var label_beech = $LabelBeech
onready var label_time = $LabelTime
onready var popup = $Popup
onready var menu = $Menu
#time in seconds for game
var totaltime = 900
var timediv

# Called when the node enters the scene tree for the first time.
func _ready():
	dayTimer.start(totaltime)
	timediv = totaltime / 30
	label_time.text = "noch %s Tage" % TimerToDays(dayTimer.time_left)
	label_beech.text = "Buchen: 0 | 0"
	
func _physics_process(delta):
	label_time.text = "noch %s Tage" % TimerToDays(dayTimer.time_left)
	if TimerToDays(dayTimer.time_left) == 0:
		menu.GameFinished(false)

func TimerToDays(timeval: float = 0):
	return round(timeval / timediv)
	#return round(timeval)

func _on_Menu_NewGame():
	emit_signal("NewGame")
	dayTimer.start(totaltime)

func _on_Christine_BeechChopped(inventory, count):
	label_beech.text = "Buchen: %s | %s" % [count, inventory]

func _on_Christine_BeechesExceeded():
	popup.PopupWithText("Ihr seid voll mit Buchen! Ladet sie am Schloss ab um den Komtur zu besänftigen!")
	popup.visible = true
