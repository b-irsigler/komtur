extends CanvasLayer
class_name CanvasBlur 

onready var screen_blur = $ScreenBlur
onready var tween = $Tween
var cur_amount = 0.0


func _ready():
	Global.blur = self
	screen_blur.material.set("shader_param/blur_amount", 0.0)


func _start_blur(duration: float = 0.3, blur_amount: float = 1.0) -> void:
	tween.interpolate_property(screen_blur.material, "shader_param/blur_amount", cur_amount, blur_amount, duration)
	tween.start()
	cur_amount = blur_amount


func _start_deblur(duration: float = 0.3, initial_amount: float = -1.0) -> void:
	if initial_amount < 0.0:
		initial_amount = screen_blur.material.get("shader_param/blur_amount")
	tween.interpolate_property(screen_blur.material, "shader_param/blur_amount", initial_amount, 0.0, duration)
	tween.start()
	cur_amount = 0.0


#fade to black and blur and back again :D
func _fade_and_deblur():
	tween.interpolate_property(screen_blur, "modulate", Color(0,0,0,0), Color(0,0,0,1), 0.3,Tween.TRANS_SINE,Tween.EASE_IN_OUT, 0.0)
	tween.interpolate_property(screen_blur.material, "shader_param/blur_amount", 0.0, 2.0, 0.3,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 0.0)
	tween.interpolate_property(screen_blur, "modulate", Color(0,0,0,1), Color(0,0,0,0), 0.3,Tween.TRANS_SINE,Tween.EASE_IN_OUT, 0.7)
	tween.interpolate_property(screen_blur.material, "shader_param/blur_amount", 3.0, 0.0, 2.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 0.7)
	tween.start()
