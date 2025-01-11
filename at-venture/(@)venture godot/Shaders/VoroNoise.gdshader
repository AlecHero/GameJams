shader_type canvas_item;

vec2 rand2(vec2 coord) {
	coord = mod(coord, 10000.0);
	return fract(sin(vec2(dot(coord, vec2(127.1, 311.7)), dot(coord, vec2(269.5, 183.3)))) * 43758.5453);
}

float cell_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float min_dist = 999.;
	for (float x = -1.0; x <= 1.0; x++) {
		for (float y = -1.0; y <= 1.0; y++) {
			vec2 node = rand2(i + vec2(x,y)) + vec2(x, y);
			float dist = sqrt((f - node).x * (f - node).x + (f - node).y * (f - node).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

void fragment() {
	vec2 uv = UV * 10.0;
	COLOR.rgb = vec3(cell_noise(uv));
}