shader_type canvas_item;

uniform float rot_speed = 20.0;
uniform float rot_angle : hint_range(0, 180, 5) = 45.0;
uniform vec2 center = vec2(8,8);
uniform float squish_amount : hint_range(-3.0, 1.8) = 0.0;

vec2 rot_displacement(vec2 vertex, float time, float speed) {
	vec4 vertex_position = vec4(vertex, 0.0, 1.0);
	float angle = sin(speed*time)*(PI*rot_angle/180.0);
	vec2 displacement = vertex_position.xy - center;
	mat2 rotation_matrix = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	displacement = rotation_matrix * displacement;

	return (vec2(center) + displacement) / vec2(1);
}

vec2 squish_displacement(vec2 vertex, float time) {
	vec4 vertex_position = vec4(vertex, 0.0, 1.0);
	vec2 displacement = vertex_position.xy - center;

	displacement *= vec2(1.0 + 0.3*squish_amount,1.0 - 0.5*squish_amount);
	return (vec2(center) + displacement) / vec2(1);
}

void vertex() {
	VERTEX = rot_displacement(VERTEX, TIME, rot_speed);
	VERTEX = squish_displacement(VERTEX, TIME);
}