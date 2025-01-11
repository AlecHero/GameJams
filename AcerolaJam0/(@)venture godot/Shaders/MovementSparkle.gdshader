shader_type canvas_item;

uniform float speed = 0.0;
uniform vec2 center = vec2(128,128);

void vertex() {
	float final_speed;
	vec4 vertex_position = vec4(VERTEX, 0.0, 1.0);
	
	//float angle = sin(speed * (mod(TIME, speed*2.0*PI)))/4.0;
	float angle = sin(speed * TIME)/4.0;
	vec2 displacement = vertex_position.xy - center;
	mat2 rotation_matrix = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	displacement = rotation_matrix * displacement;
	VERTEX = (vec2(center) + displacement) / vec2(1);
}