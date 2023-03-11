shader_type canvas_item;

uniform float blur_amount;

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
}