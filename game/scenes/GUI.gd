extends CanvasLayer

signal NewGame
onready var dayTimer = $"30Tage"
onready var label_beech = $LabelBeech
onready var label_time = $LabelTime
onready var castle =$"../Castle"
onready var popup = $Popup
onready var menu = $Menu
onready var camera = $"../Christine/Camera2D"
onready var castleIndicator = $CastleIndicator
#time in seconds for game
var totaltime = 600
var timediv

func _ready():
	dayTimer.start(totaltime)
	timediv = totaltime / 30
	label_time.text = "noch %s Tage" % TimerToDays(dayTimer.time_left)
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [0, 0]
	
func _physics_process(delta):
	label_time.text = "noch %s Tage" % TimerToDays(dayTimer.time_left)
	if TimerToDays(dayTimer.time_left) == 0:
		menu.GameFinished(false)
	updateCastleIndicator()
	
func TimerToDays(timeval: float = 0):
	return round(timeval / timediv)

func _on_Menu_NewGame():
	emit_signal("NewGame")
	dayTimer.start(totaltime)

func _on_Christine_BeechChopped(inventory, count):
	label_beech.text = "Buchen im Schloss: %s | getragen: %s" % [count, inventory]
	if count >= 100:
		menu.GameFinished(true)

func _on_Christine_BeechesExceeded():
	popup.PopupWithText("Ihr seid voll mit Buchen! Ladet sie am Schloss ab um den Komtur zu besänftigen!")
	popup.visible = true
	
func updateCastleIndicator():
	var center = camera.get_camera_screen_center()
	var target = castle.position
	var vec = target - center
	var margin = castleIndicator.rect_size * 0.5
	var half_size = get_viewport().size * 0.5
	var clamped_vec = Vector2 (
			clamp(vec.x, -half_size.x, half_size.x - margin.x),
			clamp(vec.y, -half_size.y, half_size.y - margin.y)
		)
	if clamped_vec == vec:
		castleIndicator.visible = false
	else:
		castleIndicator.visible = true
	castleIndicator.rect_position = clamped_vec + half_size

func _on_Komtur_KomturAttack():
	#subtracts one day from game Time
	var curTime = dayTimer.time_left
	dayTimer.start(curTime-timediv)

func _on_DerGruene_DerGrueneConversation(active):
	popup.PopupWithText("Versprecht ihr ein ungetauftes Kind fuer ein Dutzend Buchen? (y/n)")
	popup.visible = active

func _on_Christine_DealAccepted():
	popup.visible = false
