shader_type canvas_item;

//uniform vec2 direction;
uniform float angle;
uniform float spacing = 0.025;
varying vec2 vert;

void vertex() {
	vert = VERTEX;
}

void fragment() {
	if (COLOR.a != 0.0) {
		float rotated_vert = (-cos(angle)*vert.x + -sin(angle)*vert.y) * spacing;
		COLOR.rgb = vec3(step(mod(rotated_vert + TIME, 0.5), 0.2));
	}
}