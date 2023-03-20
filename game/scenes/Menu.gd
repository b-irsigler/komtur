extends Control

signal new_game
signal name_entered(name)

export(NodePath) var _game_timer
export(NodePath) var _world_gen

var is_paused = false setget set_is_paused

onready var menu_reason = $CenterContainer/VBoxContainer/MenuReason
onready var menu_resume = $CenterContainer/VBoxContainer/ButtonResume
onready var menu_tutorial = $CenterContainer/VBoxContainer/ButtonTutorial
onready var menu_debug = $CenterContainer/VBoxContainer/CheckBoxDebug
onready var text_input = $CenterContainer/VBoxContainer/LineEdit
onready var highscore = $CenterContainer/VBoxContainer/Highscore


func _ready():
	visible = false


#setting the is_paused variable will execute this function:
#toggles menu visibility and game pause mode
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func game_finished(is_won):
	self.is_paused = true
	menu_resume.visible = false
	if is_won:
		var game_timer = get_node(_game_timer)
		var world_gen = get_node(_world_gen)
		var score = int(game_timer.time_left * world_gen.first_100_beeches)
		menu_reason.text = "Gewonnen mit %s Punkten." % Utils.number_to_separated(score)
		text_input.align = LineEdit.ALIGN_CENTER
		text_input.set_placeholder("Name")
		text_input.visible = true
		var name = yield(text_input,"text_entered")
		emit_signal("name_entered", name)
		text_input.visible = false
		highscore.visible = true
	else:
		menu_reason.text = "Verloren!"


func _on_ButtonResume_pressed():
	self.is_paused = false


func _on_ButtonExit_pressed():
	get_tree().quit()


func _on_ButtonNew_pressed():
	emit_signal("new_game")
	self.is_paused = false
