extends StaticBody2D

onready var ischopped = false
onready var chopfx = $AnimationLeafspell
onready var beechsprite = $Oaktree
onready var hole = $Hole
onready var effect = $Spritetween
onready var collision = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	effect.interpolate_property(beechsprite, 'scale', beechsprite.get_scale(), Vector2(0.1, 0.1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	#pass

func chop():
	ischopped = true
	chopfx.visible = true
	chopfx.play()
	effect.start()
	hole.visible = true
	collision.disabled = true
	#queue_free()

func _on_Spritetween_tween_completed(_object, _key):
	beechsprite.visible = false
