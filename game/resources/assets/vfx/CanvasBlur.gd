extends CanvasLayer


onready var screen_blur = $ScreenBlur
onready var tween = $Tween
var cur_amount = 0.0


func _ready():
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
