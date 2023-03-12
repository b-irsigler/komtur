extends Button

onready var blur = $"../../CanvasBlur"
onready var sw = $"../../CanvasShockwave"
var switch = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonTest_pressed():
	if switch:
		blur._start_blur()
		switch = false
	else:
		blur._start_deblur()
		switch = true
