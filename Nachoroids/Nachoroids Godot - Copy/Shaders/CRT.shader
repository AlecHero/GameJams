shader_type canvas_item;

uniform float scan_line_count : hint_range(0, 1080) = 225.0;
uniform float scan_line_contrast : hint_range(0.1, 1.0, 0.1) = 0.5;
uniform float scan_line_thickness : hint_range(0.1, 1.5, 0.05) = 0.25;

uniform float horizontal_curve : hint_range(1.0, 5.0, 0.25) = 4.0;
uniform float vertical_curve : hint_range(1.0, 5.0, 0.25) = 3.0;

vec2 uv_curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv.x *= 1.0 + pow(abs(uv.y) / horizontal_curve, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / vertical_curve, 2.0);
	uv = (uv / 2.0) + 0.5;
	return uv;
}

void fragment() {
	float PI = 3.14159;
	float r = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV), 0.0).r;
	float g = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV), 1.0).g;
	float b = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV), -1.0).b;
	
	float s = sin(uv_curve(SCREEN_UV).y * scan_line_count * PI * 2.0);
	s = (s * scan_line_contrast + 0.6);
	vec4 scan_line = vec4(vec3(pow(s, scan_line_thickness)), 1.0);
	
	COLOR = vec4(r,g,b, 1.0) * scan_line;
}