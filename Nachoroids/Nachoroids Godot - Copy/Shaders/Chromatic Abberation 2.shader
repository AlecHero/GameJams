shader_type canvas_item;

uniform float color_bleeding = 0.8;
uniform float bleeding_range = 3.0;
uniform float screen_width = 1024;

void fragment()
{
	float pixel_size = 1.0/screen_width*bleeding_range;
	vec4 color_left = texture(SCREEN_TEXTURE,SCREEN_UV - vec2(pixel_size, 0));
	vec4 current_color = texture(SCREEN_TEXTURE,SCREEN_UV);
	current_color = current_color*vec4(color_bleeding,0.5,0.25,1);
	color_left = color_left*vec4(0.25,0.5,color_bleeding,1);
	COLOR.rgba = (current_color + color_left);
}