shader_type canvas_item;

uniform bool is_activated = false;
uniform float t : hint_range(0.0, 1.0);

void vertex() {
	if (is_activated) {
		float x = (1.+4./16.);
		VERTEX = VERTEX * x;
		VERTEX -= x*2.5;
	}
}

void fragment() {
	if (UV.y > 1.0-t) {
		COLOR.rgb += vec3(0.5);
	}
}