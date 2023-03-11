extends CanvasLayer

func _start_shockwave_shader(position: Vector2, final_size: float = 0.3, duration: float = 0.4, thickness: float = 0.05, force: float = 0.05) -> void:
	var shader_shockwave = $ScreenShockwave
	shader_shockwave.material.set("shader_param/center", position)
	shader_shockwave.material.set("shader_param/thickness", thickness)
	shader_shockwave.material.set("shader_param/force", force)
	shader_shockwave.material.set("shader_param/size", 0.0)
	var fx = create_tween()
	fx.set_trans(Tween.TRANS_QUAD)
	fx.set_parallel(true)
	fx.tween_property(shader_shockwave.material, "shader_param/size", final_size, duration)
	fx.tween_property(shader_shockwave.material, "shader_param/force", 0.0, duration)
