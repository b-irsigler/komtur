extends StaticBody2D

onready var ischopped = false
onready var chopfx = $AnimationLeafspell
onready var beechsprite = $Oaktree
onready var hole = $Hole
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func chop():
	ischopped = true
	chopfx.visible = true
	chopfx.play()
	tween.interpolate_property(beechsprite, "transform/scale", null, Vector2(0,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()
	beechsprite.visible = false
	hole.visible = true
	#queue_free()

