extends CanvasLayer

signal NewGame
onready var dayTimer = $"30Tage"
onready var label_beech = $LabelBeech
onready var label_time = $LabelTime
onready var popup = $Popup

# Called when the node enters the scene tree for the first time.
func _ready():
	label_time.text = "noch %s Tage" % round(dayTimer.time_left / 60)

func _on_Menu_NewGame():
	emit_signal("NewGame")

func _on_Christine_BeechChopped(inventory, count):
	label_beech.text = "Buchen: %s | %s" % [count, inventory]

func _on_Christine_BeechesExceeded():
	popup.PopupWithText("Ihr seid voll mit Buchen! Ladet sie am Schloss ab um den Komtur zu besänftigen!")
	popup.visible = true
