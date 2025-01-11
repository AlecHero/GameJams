shader_type canvas_item;

uniform vec4 primary : source_color = vec4(1.0);
uniform vec4 secondary : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	if (color.rgb == vec3(1.0,0.0,0.0)) {
		COLOR = secondary;
	} else {
		float ratio = color.g;
		COLOR = mix(secondary, primary, ratio);
	}
}