extends StaticBody2D


var is_chopped = false
var chopping_progress = 100
var is_selected = false
var is_being_chopped = false
var outline_color = Color(1, 1, 1, 0)
var time = 0
var outline_frequency = 5

onready var chop_fx = $AnimationLeafspell
onready var beech_sprite = $Oaktree
onready var hole_sprite = $Hole
onready var effect = $Spritetween
onready var collision = $CollisionShape2D


func _ready():
	effect.interpolate_property(beech_sprite, 'scale', beech_sprite.get_scale(), Vector2(0.1, 0.1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)


func _physics_process(delta):
	if is_selected:
		time += delta
		if is_being_chopped:
			outline_frequency = 20
		else:
			outline_frequency = 5
		outline_color = Color(1, 1, 1, .5 + .5 * pow(sin(outline_frequency * time), 2))
	else:
		time = 0
		outline_color = Color(1, 1, 1, 0)
	beech_sprite.get_material().set_shader_param("outline_color", outline_color)


func chop():
	is_being_chopped = true
	chopping_progress -= 1
	if chopping_progress <= 0:
		is_chopped = true
		chop_fx.visible = true
		chop_fx.play()
		effect.start()
		hole_sprite.visible = true
		collision.disabled = true
	return is_chopped


func _on_Spritetween_tween_completed(_object, _key):
	beech_sprite.visible = false
