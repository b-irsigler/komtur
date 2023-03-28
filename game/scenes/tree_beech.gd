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
onready var progress = $ProgressChop
onready var shadow = $Shadow


func _ready():
	effect.interpolate_property(beech_sprite, 'scale', beech_sprite.get_scale(), Vector2(0.1, 0.1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	progress.visible = false
	var beech_sprite_size = beech_sprite.texture.get_size()
	var shear = 0.5
	shadow.get_material().set_shader_param("shear", shear)
	var shadow_sprite_size = beech_sprite_size + Vector2(beech_sprite_size.y * shear, 0)
	var beech_sprite_position = beech_sprite.position
	var shadow_sprite_position = beech_sprite_position + Vector2(beech_sprite_size.y/2 * shear, 0)
	shadow.set_position(shadow_sprite_position)
	shadow.set_region_rect(Rect2(Vector2.ZERO, shadow_sprite_size))


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
