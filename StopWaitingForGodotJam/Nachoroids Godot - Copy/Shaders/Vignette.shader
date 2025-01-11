shader_type canvas_item;
render_mode unshaded, blend_add;

uniform sampler2D gradient : hint_black;

uniform float MULTIPLIER = -1.0;
uniform float opacity = 0.0;
uniform float SCALE = 0.1;
uniform float SOFTNESS = 13.0;

void fragment(){
	float val = distance(vec2(UV.x , UV.y * MULTIPLIER), vec2(0.5, 0.5 * MULTIPLIER));
	val = val / SCALE;
	float vignette = smoothstep(0.2, SOFTNESS, val);
	
	COLOR = vec4(texture(gradient, vec2(vignette)).rgb, vignette * opacity);
	
}