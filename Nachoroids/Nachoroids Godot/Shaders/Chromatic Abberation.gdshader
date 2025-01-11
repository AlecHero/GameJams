shader_type canvas_item;

uniform float amount = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest; 

void fragment() {
//	vec2 ps = SCREEN_PIXEL_SIZE;
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float adjusted_amount = amount / 750.0;
	color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_amount, SCREEN_UV.y)).r;
	color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_amount, SCREEN_UV.y)).b;
	
	COLOR = color;
}