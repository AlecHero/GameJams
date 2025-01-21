shader_type canvas_item;
uniform float dir_factor;

const float angle = PI * 3.0/4.0;
const float angle2 = PI/4.0;
const mat2 rot_pos = mat2(vec2(sin(angle), -cos(angle)), vec2(cos(angle), sin(angle)));
const mat2 rot_neg = mat2(vec2(sin(angle2), -cos(angle2)), vec2(cos(angle2), sin(angle2)));

void vertex() {
	vec2 pivot = vec2(16.0, -16.0);
	VERTEX -= pivot;
	VERTEX *= rot_pos;
	VERTEX.x *= dir_factor;
	VERTEX *= rot_neg;
	VERTEX += pivot;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
