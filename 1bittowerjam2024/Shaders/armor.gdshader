shader_type canvas_item;

uniform float t = 0.0;
uniform float amplitude = 10.0;
uniform float frequecy = 20.0;
uniform bool x_axis = true;

void vertex() {
	float exponent = mod(t, 3.0);
	if (x_axis) {
		VERTEX.x += amplitude * exp(-3.0*exponent) * sin(frequecy*exponent);
	} else {
		VERTEX.y += amplitude * exp(-3.0*exponent) * sin(frequecy*exponent);
	}
}

void fragment() {
	float exponent = mod(t, 3.0);
	vec4 tex = texture(TEXTURE, UV);
	COLOR.rgb = tex.rgb + vec3(0.0) * exp(-3.0*exponent);
}
