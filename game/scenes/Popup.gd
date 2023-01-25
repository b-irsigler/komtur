extends Control

onready var popup_label = $PopupLabel
onready var popup_tween = $PopupTween

# Called when the node enters the scene tree for the first time.
func _ready():
	popup_label.percent_visible = 0

func show_popup(text):
	popup_label.text = text
	if popup_label.percent_visible != 0:
		popup_tween.stop_all()
	popup_label.percent_visible = 1.0
	popup_tween.interpolate_property(popup_label, 'percent_visible', 1.0, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 6.0)
	popup_tween.start()
