shader_type canvas_item;

uniform float anim_speed = 7;
uniform float squish_amount = 0.0;
uniform float alpha = 1.0;

group_uniforms beast_bools;
uniform bool is_flying = false;
uniform bool is_ghost = false;
uniform bool is_wavy = false;
uniform bool is_climby = false;
uniform bool is_dying = false;
uniform int death_type = 0;
group_uniforms;

group_uniforms sprite_sheet;
uniform float columns = 6;
uniform float rows = 2;
uniform float frame = 0;
group_uniforms;

group_uniforms slice;
uniform float angle = 0.0; // 0 - PI
uniform float t : hint_range(0, 1) = 0.0;
group_uniforms;
const float expansion = 3.0;

uniform float rand = 0.0;
const float amplitude = 8.0;
const float frequency = 15.0;


vec2 rotated(vec2 point, float theta) {
	mat2 rot = mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)));
	return rot * point;
}

vec2 rot_displacement(vec2 pos, float time, float speed) {
	float theta = sin(speed * time)/4.0;
	return rotated(pos, theta);
}

vec2 vertical_wave_displacement(vec2 vertex, float time, float amp, float freq) {
	vertex.y += amp * sin(vertex.x * freq + time * anim_speed*0.5 + rand);
	return vertex;
}

vec2 squish_displacement(vec2 vertex, float time) {
	vertex *= vec2(1.0 + 0.3*squish_amount,1.0 - 0.5*squish_amount);
	return vertex / vec2(1);
}


uniform vec4 drop_shadow_color : source_color = vec4(vec3(0), float(0.3));
uniform float shadow_offset = 0.2;
uniform float f : hint_range(0.0, 6.28, 0.1) = 3.14;

uniform float dir_factor : hint_range(-1.0, 1.0, 0.1);
uniform vec2 offset;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void vertex() {
	if (is_dying && death_type == 0) {
		VERTEX *= expansion;
	}

	VERTEX = rot_displacement(VERTEX, TIME, anim_speed);
	VERTEX = squish_displacement(VERTEX, TIME);
	
	if (is_dying && death_type == 1) {
		VERTEX = vertical_wave_displacement(VERTEX, TIME*1.5, 5.0, 0.0);
	}
	
	vec2 pivot = vec2(16.0, -16.0);
	VERTEX -= pivot;
	VERTEX *= float(1) + float(2) * abs(shadow_offset); // for shadow handling
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
	vec2 uv2 = UV * float(float(1) + float(2) * abs(shadow_offset)) - vec2(abs(shadow_offset));
	float c = 2.0*PI/4.0 * (dir_factor+1.)/2.;
	vec2 unit_circle = vec2(dir_factor*cos(f+c), sin(f+c));
	vec4 original_color = sample_texture(TEXTURE, uv2);
	unit_circle += offset;
	vec4 shadow_color = vec4(drop_shadow_color.rgb, sample_texture(TEXTURE, uv2 - unit_circle * shadow_offset).a * drop_shadow_color.a);
	vec3 ambientLightColor = vec3(1.0, 0.5, 0.3) * 0.6;
	shadow_color.rgb = mix(shadow_color.rgb, ambientLightColor, shadow_color.a);
	
	if (shadow_color.a > float(0)) {
		COLOR = mixcolor(shadow_color, original_color);
	} else {
		COLOR = original_color;
	}
	
	
	vec2 uv = UV;
	COLOR.a *= alpha;
	
	if (is_dying && death_type == 0) {
		vec2 frame_center = vec2(
			(2.0*(mod(frame, columns)+1.)-1.) / (columns*2.),
			(2.0*(mod(floor(frame/columns), rows)+1.)-1.) / (rows*2.)
		);
		uv = (uv-frame_center) * expansion + frame_center;
		
		vec2 dist = vec2(t)*2.0/(columns*rows)*vec2(cos(angle),sin(angle));
		bool is_top = (uv.x-frame_center.x)*sin(angle) - (uv.y-frame_center.y)*cos(angle) > 0.0;
		if (is_top) { uv += dist; }
		else { uv -= dist; }
		
		if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) { COLOR = vec4(0.0); }
		else { COLOR = texture(TEXTURE, uv); }
		
		COLOR.a *= 1.0-t;
	} else if (is_dying && death_type == 1) {
		COLOR.a *= 1.0-t;
	}
}