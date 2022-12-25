class_name WalkState extends BaseState

export (float) var move_speed = 60

func physics_process(delta: float) -> int:
	if !character.is_on_floor():
		return State.Fall

	var move = 0
	if Input.is_action_pressed("move_left"):
		move = -1
		character.animations.flip_h = true
	elif Input.is_action_pressed("move_right"):
		move = 1
		character.animations.flip_h = false
	
	character.velocity.y += character.gravity
	character.velocity.x = move * move_speed
	character.velocity = character.move_and_slide(character.velocity, Vector2.UP)
	
	if move == 0:
		return State.Idle

	return State.Null
	
