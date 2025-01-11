shader_type canvas_item;


vec2 rotate(vec2 uv, float r) {
	r = radians(r); //r *= (PI / 180.0); //Radians to degrees
	return uv * mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
}

uniform float speed;
void fragment() {
	vec2 uv = rotate(UV-0.5, TIME*pow(2.,speed)) + 0.5;
	vec4 tex = texture(TEXTURE, uv);
	COLOR = tex;
	COLOR.rgb = 1.0-COLOR.rgb;
}