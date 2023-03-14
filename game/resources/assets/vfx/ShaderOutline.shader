shader_type canvas_item;

uniform bool active;
uniform float outline_thickness: hint_range(1.0, 10.0) = 1.5;
uniform vec4 outline_color: hint_color = vec4(1.0);

void fragment() {
	vec4 cur_color = texture(TEXTURE, UV);
	float cur_alpha = cur_color.a;
	vec2 ps_width = TEXTURE_PIXEL_SIZE * outline_thickness;
	
	//only sample direct neighbours, not diagonals
	float outline = texture(TEXTURE, UV + ps_width * vec2(1.0,0.0)).a;
	outline += texture(TEXTURE, UV + ps_width * vec2(-1.0,0.0)).a;
	outline += texture(TEXTURE, UV + ps_width * vec2(0.0,1.0)).a;
	outline += texture(TEXTURE, UV + ps_width * vec2(0.0,-1.0)).a;
//	outline += texture(TEXTURE, UV + ps_width * vec2(-1.0,-1.0)).a;
//	outline += texture(TEXTURE, UV + ps_width * vec2(-1.0,1.0)).a;
//	outline += texture(TEXTURE, UV + ps_width * vec2(1.0,-1.0)).a;
//	outline += texture(TEXTURE, UV + ps_width * vec2(1.0,1.0)).a;
	outline = min(outline, 1.0);
	//COLOR = cur_color;
	COLOR = mix(cur_color, outline_color , outline - cur_alpha);
}