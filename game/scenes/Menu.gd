extends Control

var is_paused = false setget set_is_paused

#Negates current is_paused state if Esc is pressed
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.is_paused = !is_paused

#setting the is_paused variable will execute this function:
#toggles menu visibility and game pause mode
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_ButtonResume_pressed():
	self.is_paused = false

func _on_ButtonExit_pressed():
	get_tree().quit()
