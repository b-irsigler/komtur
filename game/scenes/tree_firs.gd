extends StaticBody2D

onready var sprite = $Firtree
onready var shadow = $Shadow

func _ready():
	var sprite_size = sprite.texture.get_size()
	var shear = 0.5
	shadow.get_material().set_shader_param("shear", shear)
	var shadow_sprite_size = sprite_size + Vector2(sprite_size.y * shear, 0)
	var sprite_position = sprite.position
	var shadow_sprite_position = sprite_position + Vector2(sprite_size.y/2 * shear, 0)
	shadow.set_position(shadow_sprite_position)
	shadow.set_region_rect(Rect2(Vector2.ZERO, shadow_sprite_size))
