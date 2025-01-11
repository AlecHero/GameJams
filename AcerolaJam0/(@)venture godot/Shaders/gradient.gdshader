shader_type canvas_item;

uniform float feather;
uniform float radius;
uniform vec4 color : source_color;

float circle(vec2 position, float r, float f) {
	return 1.0-smoothstep(r, r + f, dot(position, position) * 4.0);
}

vec4 blend(vec4 base, vec4 blend) {
	if (base.rgb == vec3(1.0)) {
		return vec4(vec3(1.0),base.a);
	}
	return vec4(blend.rgb, min(base.a, blend.a));
}

uniform float shift_hue;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
void fragment() {
	vec4 tex = texture(screen_texture, SCREEN_UV);
	
	vec3 color_hsv;
	{
		vec3 c = tex.rgb;
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		color_hsv=vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}
	
	color_hsv.x = mod((color_hsv.x + shift_hue), 1.0f);
	
	// VectorFunc:5
	vec3 color_rgb;
	{
		vec3 c = color_hsv;
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		color_rgb=c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}
	
	
	float circ = circle(UV -.5, radius, feather);
	COLOR = vec4(color_rgb.rgb, circ);
}