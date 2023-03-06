extends Control

signal text_intro_button_pressed

onready var text_intro = $TextIntro
onready var button = $CenterContainer/Button
onready var tween = $TweenText


func _ready():
	visible = false
	tween.connect("tween_all_completed", self, "_on_tween_completed")
	button.connect("pressed", self, "_on_button_pressed")


func _start():
	get_tree().paused = true
	text_intro.percent_visible = 0
	visible = true
	button.visible = false
	button.text = "Spiel Starten"
	tween.interpolate_property(text_intro, 'percent_visible', 0, 1.0, 15.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.start()


func interrupt_text():
	tween.stop_all()
	text_intro.percent_visible = 1
	button.visible = true

func _on_tween_completed():
	button.visible = true


func _on_button_pressed():
	visible = false
	get_tree().paused = false
	emit_signal("text_intro_button_pressed")
