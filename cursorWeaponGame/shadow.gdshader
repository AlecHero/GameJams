shader_type canvas_item;

uniform vec4 drop_shadow_color : source_color = vec4(vec3(0), float(0.3));
uniform float shadow_offset = 0.2;
uniform float f : hint_range(0.0, 6.28, 0.1) = 3.14;

uniform float dir_factor : hint_range(-1.0, 1.0, 0.1);
uniform vec2 offset;
uniform float alpha = 1.0;

const float angle = PI * 3.0/4.0;
const float angle2 = PI/4.0;
const mat2 rot_pos = mat2(vec2(sin(angle), -cos(angle)), vec2(cos(angle), sin(angle)));
const mat2 rot_neg = mat2(vec2(sin(angle2), -cos(angle2)), vec2(cos(angle2), sin(angle2)));


uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	vec2 pivot = vec2(16.0, -16.0);
	VERTEX -= pivot;
	VERTEX *= float(1) + float(2) * abs(shadow_offset); // for shadow handling
	VERTEX *= rot_pos;
	VERTEX.x *= dir_factor;
	VERTEX *= rot_neg;
	VERTEX += pivot;
}


vec4 sample_texture(sampler2D texture, vec2 uv)  {
	if ((uv.x < 0.0 || uv.x > 1.0) || (uv.y < 0.0 || uv.y > 1.0))  {
		return vec4(0.0);
	} else {
		return texture(texture, uv);
	}
}

vec4 mixcolor(vec4 colA, vec4 colB)  {
	return vec4((colA.rgb + colB.a * (colB.rgb - colA.rgb)), colA.a + colB.a);
}

void fragment()  {
	vec2 uv = UV * float(float(1) + float(2) * abs(shadow_offset)) - vec2(abs(shadow_offset));
	float c = 2.0*PI/4.0 * (dir_factor+1.)/2.;
	vec2 unit_circle = vec2(dir_factor*cos(f+c), sin(f+c));
	vec4 original_color = sample_texture(TEXTURE, uv);
	unit_circle += offset;
	vec4 shadow_color = vec4(drop_shadow_color.rgb, sample_texture(TEXTURE, uv - unit_circle * shadow_offset).a * drop_shadow_color.a);
	vec3 ambientLightColor = vec3(1.0, 0.5, 0.3) * 0.6;
	shadow_color.rgb = mix(shadow_color.rgb, ambientLightColor, shadow_color.a);
	
	if (shadow_color.a > float(0)) {
		COLOR = mixcolor(shadow_color, original_color);
	} else {
		COLOR = original_color;
	}
	COLOR.a *= alpha;
}