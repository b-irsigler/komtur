extends CanvasLayer


onready var screen_blur = $ScreenBlur
#onready var fx = create_tween()

func _ready():
	screen_blur.material.set("shader_param/blur_amount", 0.0)
	visible = false

#tweens not working here, so no durations -.-
func _start_blur(duration: float = 0.2, blur_amount: float = 1.0) -> void:
	visible = true
	screen_blur.material.set("shader_param/blur_amount", blur_amount)

func _start_deblur(duration: float = 0.2) -> void:
	screen_blur.material.set("shader_param/blur_amount", 0.0)
	visible = false
