shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5); // +- 0.5
uniform float angle = 0.0; // 0 - PI
uniform float t : hint_range(0, 1) = 0.0;

void vertex() {
	VERTEX *= 4.0;
	UV = (UV-0.5) * 4.0 + 0.5;
}

vec2 rotated(vec2 point, float theta) {
	mat2 rot = mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)));
	return rot * point;
}

void fragment() {
	vec2 uv = UV;
	vec2 dist = vec2(t*1.5) * vec2(cos(angle),sin(angle));
	bool is_top = (uv.x-center.x)*sin(angle) - (uv.y-center.y)*cos(angle) > 0.0;
	if (is_top) { uv += dist; }
	else { uv -= dist; }
	
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) { COLOR = vec4(0.0); }
	else { COLOR = texture(TEXTURE, uv); }
	COLOR.a *= 1.0-(max(0, t-0.3)*3.0);
}