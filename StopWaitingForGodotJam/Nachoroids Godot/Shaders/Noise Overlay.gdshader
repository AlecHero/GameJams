shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest; 
uniform float overlay_number : hint_range(0.05, 1.0, 0.05) = 0.25;

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(1.0, base);
	return mix(2.0 * base * blend, (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)) * overlay_number, limit);
	//https://godotshaders.com/snippet/blending-modes/
}

float rand(vec2 coord){
	// prevents randomness decreasing from coordinates too large
	coord = mod(coord, 100.0);
	// returns "random" float between 0 and 1
	return fract(sin(dot(coord, vec2(12.9898,78.233))) * 43758.5453);
}
//https://www.youtube.com/watch?v=ybbJz6C9YYA
void fragment() {
	vec2 coord = UV * 10.0;
	//float value = rand(coord + vec2(int(TIME) % 5000));
	float value = rand(coord * TIME);
	COLOR = vec4(vec3(value), 1.0);
	COLOR = overlay(texture(SCREEN_TEXTURE, SCREEN_UV), COLOR);
}