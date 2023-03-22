extends Sprite

var IND_COL = {"YELLOW" : Color(1,.84,0,1)}

onready var viewport = get_viewport()
onready var margin = Vector2(20,20)
onready var half_size = viewport.size * 0.5 - Vector2(10,10)

func change_color(color_value):
	modulate = color_value

func update_indicator(target_position: Vector2) -> void:
	var center = Global.camera.get_camera_screen_center()
	var displacement = target_position - center
	#var margin = actual_size
	var clamped_displacement = Vector2(
		clamp(displacement.x, -half_size.x, half_size.x - margin.x),
		clamp(displacement.y, -half_size.y, half_size.y - margin.y)
		)
	if clamped_displacement == displacement:
		self.visible = false
	else:
		self.visible = true
	self.position = clamped_displacement + half_size + margin
	self.rotation_degrees = rad2deg(displacement.angle()) + 90
