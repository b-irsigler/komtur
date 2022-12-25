extends BaseState

export (float) var jump_force = 100
export (float) var move_speed = 60

func enter() -> void:
	# This calls the base class enter function, which is necessary here
	# to make sure the animation switches
	.enter()
	character.velocity.y = -jump_force

func physics_process(delta: float) -> int:
	var move = 0
	if Input.is_action_pressed("move_left"):
		move = -1
		character.animations.flip_h = true
	elif Input.is_action_pressed("move_right"):
		move = 1
		character.animations.flip_h = false
	
	character.velocity.x = move * move_speed
	character.velocity.y += character.gravity
	character.velocity = character.move_and_slide(character.velocity, Vector2.UP)
	
	if character.velocity.y > 0:
		return State.Fall

	if character.is_on_floor():
		if move != 0:
			return State.Walk
		else:
			return State.Idle
	return State.Null
