shader_type canvas_item;
uniform float frequency = 16.0; // Controls the number of dots
uniform float phase_speed = 4.0;
uniform float size : hint_range(-1.0, 1.0) = 0.0;
uniform float t : hint_range(0.5, 1.0) = 0.95;
uniform bool is_square = true;
uniform bool is_line = false;

void fragment() {
	vec2 uv = UV-vec2(.5);
	float wave = sin(frequency * atan(uv.x, uv.y) + TIME*phase_speed);
	//COLOR.a = step(wave, size);
	COLOR.rgb = vec3(step(wave, size));
	
	if (is_square) {
		if (UV.x < t && UV.x > 1.0-t && UV.y < t && UV.y > 1.0-t) { COLOR.a = 0.0; }
	} else if (is_line) {
		COLOR.rg = UV;
	} else {
		if (!(length(uv) < .5 && length(uv) > (t-.5))) { COLOR.a = 0.0; }
	}
}