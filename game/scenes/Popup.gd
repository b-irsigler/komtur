extends Control

onready var polabel = $PopupLabel
onready var potween = $PopupTween

# Called when the node enters the scene tree for the first time.
func _ready():
	polabel.percent_visible = 0

func PopupWithText(PopupText):
	polabel.text = PopupText
	polabel.percent_visible = 1.0
	potween.interpolate_property(polabel, 'percent_visible', 1.0, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 3.0)
	potween.start()
