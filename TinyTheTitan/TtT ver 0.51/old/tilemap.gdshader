shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float alpha = 1.0;
uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;
uniform float pixels : hint_range(0.0, 1.0) = 1.0;
uniform vec2 world_offset;
//vec2 quantize(vec2 uv, float pixelation) {
    //return floor(uv * pixelation) / pixelation;
//}
vec2 quantize(vec2 fragcoord, float pixel_size, vec2 offset) {
    float x = fragcoord.x - mod(fragcoord.x, pixel_size);
	float y = fragcoord.y - mod(fragcoord.y, pixel_size);
	float shift = floor(pixel_size / 2.0);
	return vec2(x+shift, y+shift);
}

void fragment() {
	vec2 uv = UV;
	//uv = quantize(uv, 32./1152., world_offset);
	
	float x = abs(uv.r-.5)*2.0;
	float y = abs(uv.g-.5)*3.0;
	float q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius)/(1.0-inner_radius);
	vec3 tex = texture(TEXTURE, UV).rgb;
	COLOR = vec4(tex, q*alpha);
}