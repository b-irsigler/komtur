extends Control

signal new_game
var is_paused = false setget set_is_paused
onready var menu_reason = $CenterContainer/VBoxContainer/MenuReason
onready var menu_resume = $CenterContainer/VBoxContainer/ButtonResume


#Negates current is_paused state if Esc is pressed
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.is_paused = !is_paused
		menu_resume.visible = true
		menu_reason.text = "Spiel Pausiert"

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
		menu_reason.text = "Gewonnen!"
	else:
		menu_reason.text = "Verloren!"


func _on_ButtonResume_pressed():
	self.is_paused = false


func _on_ButtonExit_pressed():
	get_tree().quit()


func _on_ButtonNew_pressed():
	print("_on_ButtonNew_pressed() Menu")
	emit_signal("new_game")
	self.is_paused = false
