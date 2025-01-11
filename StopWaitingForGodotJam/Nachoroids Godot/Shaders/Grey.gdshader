shader_type canvas_item;
uniform float opacity = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest; 

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	COLOR.rgb = vec3(avg);
	
	COLOR = max(COLOR, texture(TEXTURE, UV) * opacity);
}