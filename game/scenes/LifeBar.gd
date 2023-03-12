extends ProgressBar


onready var g = range_lerp(10, 2, 10, 0, .84)
onready var styleBox = get("custom_styles/fg")
onready var tween = $LifeBarTween
var oldval


func _ready():
	update_health(10)


func update_health(new_value):
	g = range_lerp(new_value, 2, 10, 0, .84)
	styleBox.modulate_color = Color(1, g, 0)
	oldval = value
	tween.interpolate_property(self, "value", oldval, new_value, 0.1)
	tween.start()
	if new_value == 10:
		visible = false
	else: 
		visible = true
