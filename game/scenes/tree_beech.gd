extends StaticBody2D

var is_chopped = false
var chopping_progress = 100

onready var chop_fx = $AnimationLeafspell
onready var beech_sprite = $Oaktree
onready var hole_sprite = $Hole
onready var effect = $Spritetween
onready var collision = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	effect.interpolate_property(beech_sprite, 'scale', beech_sprite.get_scale(), Vector2(0.1, 0.1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	#pass

func chop():
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
