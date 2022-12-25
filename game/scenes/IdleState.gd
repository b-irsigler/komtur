class_name IdleState extends BaseState

func input(event: InputEvent) -> int:
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		return State.Walk
	elif Input.is_action_just_pressed("jump"):
		return State.Jump
	return State.Null

func physics_process(delta: float) -> int:
	character.velocity.y += character.gravity
	character.velocity = character.move_and_slide(character.velocity, Vector2.UP)

	if !character.is_on_floor():
		return State.Fall
	return State.Null
