shader_type canvas_item;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

uniform bool do_rainbow = false;
uniform float density = 10.0;
uniform float speed = 20.0;
uniform bool non_uniform_rainbow = true;
uniform float factor = 0.0;
void fragment() {
	float uv_c = float(non_uniform_rainbow)*(SCREEN_UV.x*factor - SCREEN_UV.y) + TIME/speed;
	if (do_rainbow) { COLOR.rgb = hsv2rgb(vec3(uv_c * density, 1.0, 1.0)); }
}