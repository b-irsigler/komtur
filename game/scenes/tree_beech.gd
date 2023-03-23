extends StaticBody2D


var is_chopped = false
var chopping_progress = 100
var is_selected = false
var is_being_chopped = false
var outline_color = Color(1, .84, 0, 0)
var time = 0
var outline_frequency = 5

onready var chop_fx = $AnimationLeafspell
onready var beech_sprite = $Oaktree
onready var hole_sprite = $Hole
onready var effect = $Spritetween
onready var collision = $CollisionShape2D
onready var progress = $ProgressChop


func _ready():
	effect.interpolate_property(beech_sprite, 'scale', beech_sprite.get_scale(), Vector2(0.1, 0.1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	beech_sprite.get_material().set_shader_param("outline_color", outline_color)
	progress.visible = false


func set_outline(tree_selected: bool):
	if tree_selected:
		beech_sprite.get_material().set_shader_param("frequency", 5.0)
		outline_color.a = 1
	else:
		beech_sprite.get_material().set_shader_param("frequency", 0.0)
		outline_color.a = 0
	beech_sprite.get_material().set_shader_param("outline_color", outline_color)


func chop():
	is_being_chopped = true
	beech_sprite.get_material().set_shader_param("frequency", 10.0)
	progress.visible = true
	chopping_progress -= 1
	progress.value = chopping_progress
	if chopping_progress <= 0:
		is_chopped = true
		chop_fx.visible = true
		chop_fx.play()
		effect.start()
		hole_sprite.visible = true
		collision.disabled = true
		progress.visible = false
	return is_chopped


func _on_Spritetween_tween_completed(_object, _key):
	beech_sprite.visible = false
	beech_sprite.get_material().set_shader_param("frequency", 0.0)
