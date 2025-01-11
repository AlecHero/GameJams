shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float rows = 1;

float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Funkcja do generowania gradientu
float grad(int hash, float x, float y) {
    int h = hash & 7;  // maska hash
    float u = h < 4 ? x : y;
    float v = h < 4 ? y : x;
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

float perlin_noise(vec2 coord) {
    vec2 p = floor(coord);
    vec2 f = fract(coord);
    f = f * f * (3.0 - 2.0 * f);

    float n = p.x + p.y * 57.0;
    float res = mix(
        mix(grad(int(n + 0.0), f.x, f.y),
            grad(int(n + 1.0), f.x - 1.0, f.y), fade(f.x)),
        mix(grad(int(n + 57.0), f.x, f.y - 1.0),
            grad(int(n + 58.0), f.x - 1.0, f.y - 1.0), fade(f.x)),
        fade(f.y));
    return res;
}

void fragment() {
	vec2 uv = UV;
	float t = progress * 1.0/rows;
	uv.x += perlin_noise(UV + vec2(progress)*10.) * .05 * pow(progress, 0.4);
	
	for (int i = 0; i < int(rows); i++) {
		if ((float(i)/rows) < uv.y && uv.y < ((float(i)+1.0)/rows)) {
			uv.y += -t;
			if (uv.y <= float(i)/rows) { COLOR.rgb = vec3(0.0); }
			else 			{ COLOR = texture(TEXTURE, uv); }
		}
	}
}