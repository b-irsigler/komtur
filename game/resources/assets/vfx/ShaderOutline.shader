shader_type canvas_item;

uniform float outline_thickness: hint_range(1.0, 10.0) = 1.5;
uniform vec4 outline_color: hint_color = vec4(1.0);

void fragment() {
	vec4 cur_color = texture(TEXTURE, UV);
	
	if (outline_color.a == 0.0) {
		COLOR = cur_color;
	}
	else {
		vec2 ps_width = TEXTURE_PIXEL_SIZE * outline_thickness;
		float a;
		float maxa = cur_color.a;
		float mina = cur_color.a;

		a = texture(TEXTURE, UV + vec2(0.0, -1.0) * ps_width).a;
		maxa = max(a, maxa);
		mina = min(a, mina);

		a = texture(TEXTURE, UV + vec2(0.0, 1.0) * ps_width).a;
		maxa = max(a, maxa);
		mina = min(a, mina);

		a = texture(TEXTURE, UV + vec2(-1.0, 0.0) * ps_width).a;
		maxa = max(a, maxa);
		mina = min(a, mina);

		a = texture(TEXTURE, UV + vec2(1.0, 0.0) * ps_width).a;
		maxa = max(a, maxa);
		mina = min(a, mina);

		COLOR = mix(cur_color, outline_color, maxa - mina);
	}
}