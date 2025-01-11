shader_type canvas_item;

// IS MISSING BLOOM THINGIE
uniform float glow_strength = 1.0;

void fragment() {
	//Horizontal Glow
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 0.0)) * 0.174938;
	//color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(1.0, 0.0)) * 0.165569;
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(2.0, 0.0)) * 0.140367;
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(3.0, 0.0)) * 0.106595;
	//color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-1.0, 0.0)) * 0.165569;
	//color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-2.0, 0.0)) * 0.140367;
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-3.0, 0.0)) * 0.106595;
	
	//Vertical Glow
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 0.0)) * 0.288713;
	//color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 1.0)) * 0.233062;
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 2.0)) * 0.122581;
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -1.0)) * 0.233062;
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -2.0)) * 0.122581;
	
	color *= glow_strength;
	COLOR = color;
}