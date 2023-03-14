extends CanvasLayer

onready var shader_shockwave = $ScreenShockwave
onready var tween = $Tween

func _ready():
	shader_shockwave.material.set("shader_param/force", 0.0)


func _start_shockwave_shader(position: Vector2, final_size: float = 0.3, duration: float = 0.4, thickness: float = 0.05, force: float = 0.05) -> void:
	shader_shockwave.material.set("shader_param/center", position)
	shader_shockwave.material.set("shader_param/thickness", thickness)
	tween.interpolate_property(shader_shockwave.material, "shader_param/size", 0.0, final_size, duration)
	tween.interpolate_property(shader_shockwave.material, "shader_param/force", force, 0.0, duration)
	tween.start()
