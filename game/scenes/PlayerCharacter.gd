extends Character

var state_manager: StateManager

func _ready():
	pass # Replace with function body.

func input(event: InputEvent) -> void:
	var new_state = state_manager.current_state.input(event)
	if new_state != BaseState.State.Null:
		state_manager.change_state(new_state)
