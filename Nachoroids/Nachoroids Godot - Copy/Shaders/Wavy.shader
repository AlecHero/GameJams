shader_type canvas_item;

uniform float frequency = 60;
uniform float depth = 0.005;

void fragment() {
	vec2 uv = UV;
	uv.x += sin(uv.y * frequency + TIME) * depth;
	uv.x = clamp(uv.x, 0.0, 1.0);
	
	COLOR = texture(TEXTURE, uv);
}
