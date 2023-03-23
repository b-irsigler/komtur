extends Sprite

var IND_COL = {"YELLOW" : Color(1,.84,0,1)}

var corner = Vector2.ZERO
var neg_corner = Vector2.ZERO
var is_overlapping = false
var target = Vector2.ZERO
var angle = 0
var quadrant = 0

onready var viewport = get_viewport()
onready var margin = Vector2(10,10)
onready var half_size = viewport.size * 0.5 - Vector2(10,10)


func _get_debug():
	return "angle: %s, quadrant: %s" % [is_overlapping, target]


func _ready():
	print(Global.camera.get_camera_screen_center())

func change_color(color_value):
	modulate = color_value


func update_indicator(target_position: Vector2) -> void:
	
	var center = Global.camera.get_camera_screen_center()
	
	target = target_position
	var displacement = target_position - center
	angle = cartesian2polar(displacement.x, displacement.y)[1]
	
	if angle < cartesian2polar(-half_size.x, -half_size.y)[1]:
		quadrant = 0
		is_overlapping = Geometry.line_intersects_line_2d(-half_size,Vector2(0,1),Vector2(0,0),displacement)
	elif angle < cartesian2polar(half_size.x, -half_size.y)[1]:
		quadrant = 1
		is_overlapping = Geometry.line_intersects_line_2d(-half_size,Vector2(1,0),Vector2(0,0),displacement)
	elif angle < cartesian2polar(half_size.x, half_size.y)[1]:
		quadrant = 2
		is_overlapping = Geometry.line_intersects_line_2d(half_size,Vector2(0,1),Vector2(0,0),displacement)
	elif angle < cartesian2polar(-half_size.x, half_size.y)[1]:
		quadrant = 3
		is_overlapping = Geometry.line_intersects_line_2d(half_size,Vector2(1,0),Vector2(0,0),displacement)
	elif angle > cartesian2polar(-half_size.x, -half_size.y)[1]:
		quadrant = 0
		is_overlapping = Geometry.line_intersects_line_2d(-half_size,Vector2(0,1),Vector2(0,0),displacement)

	is_overlapping += half_size + margin
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
	target = self.position
	position = is_overlapping 
	self.rotation_degrees = rad2deg(displacement.angle()) + 90
