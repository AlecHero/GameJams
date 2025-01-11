shader_type canvas_item;

uniform float hdr_threshold = 0.25;
uniform float blur_size = 4.0;
uniform float glow_intensity = 2.5;
uniform float blend_percent = 0.4;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest; 

vec4 screen(vec4 blend, vec4 base){
	return (1.0 - (1.0 - base) * (1.0 - blend)) * blend_percent;
}

vec4 lighten(vec4 blend, vec4 base){
	return max(blend, base);
}

vec4 linear_dodge(vec4 base, vec4 blend){
	return base + blend;
}

vec4 sample_glow_pixel(sampler2D tex, vec2 uv) {
	return max(textureLod(tex, uv, blur_size) - hdr_threshold, vec4(0.0));
}

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec4 bloom = vec4(0.0);
	
	// Get blurred color from pixels considered glowing
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));
	bloom *= glow_intensity;
	
//	COLOR = bloom;
	COLOR = linear_dodge(texture(SCREEN_TEXTURE, SCREEN_UV), bloom * blend_percent);
}