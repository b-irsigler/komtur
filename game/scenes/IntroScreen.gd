extends Control

signal text_intro_button_pressed

onready var text_intro = $TextIntro
onready var button_start = $ButtonContainer/HBoxContainer/ButtonStart
onready var button_tutorial = $ButtonContainer/HBoxContainer/ButtonTutorial
onready var tween = $TweenText
onready var hint = $HintSkip
var finished = false


func _ready():
	visible = false
	tween.connect("tween_all_completed", self, "_on_tween_completed")
	button_start.connect("pressed", self, "_on_button_pressed")


func _start():
	get_tree().paused = true
	text_intro.percent_visible = 0
	visible = true
	button_start.visible = false
	button_tutorial.visible = false
	tween.interpolate_property(text_intro, 'percent_visible', 0, 1.0, 15.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.start()
	finished = false
	hint.visible = true


func interrupt_text() -> void:
	if finished:
		return
	tween.stop_all()
	text_intro.percent_visible = 1
	hint.visible = false
	button_start.visible = true
	button_start.grab_focus()
	button_tutorial.visible = true
	finished = true


func _on_tween_completed():
	button_start.visible = true
	button_tutorial.visible = true


func _on_button_pressed():
	visible = false
	get_tree().paused = false
	emit_signal("text_intro_button_pressed")
