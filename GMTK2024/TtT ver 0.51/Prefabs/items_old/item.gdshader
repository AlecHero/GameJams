shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 500.0) = 10.0;  // The height of the bobbing
uniform float speed2 : hint_range(0.0, 10.0) = 1.0;       // The speed of the bobbing
uniform float anim_speed;
uniform vec2 center;

vec2 rot_displacement(vec2 vertex, float time, float speed) {
	vec4 vertex_position = vec4(vertex, 0.0, 1.0);
	float angle = sin(time*speed)*PI*(10./180.);
	vec2 displacement = vertex_position.xy - center;
	mat2 rotation_matrix = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	displacement = rotation_matrix * displacement;

	return (vec2(center) + displacement) / vec2(1);
}

void vertex() {
    float offsetY = amplitude * sin(TIME * speed2);
	VERTEX = rot_displacement(VERTEX, TIME, anim_speed);
    VERTEX = VERTEX + vec2(0.0, offsetY) / 500.0;
}
