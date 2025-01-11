shader_type canvas_item;

uniform float anim_speed = 10.0;
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

void vertex() {
	if (is_dying && death_type == 0) {
		VERTEX *= expansion;
	}
	
	else if (is_wavy && is_flying) { VERTEX = vertical_wave_displacement(VERTEX, TIME, 0.5, 0.0); }
	else if (is_ghost) { VERTEX = vertical_wave_displacement(VERTEX, TIME, 1.0, 5.0); }
	else if (is_flying) { VERTEX = vertical_wave_displacement(VERTEX, TIME*1.5, 1.0, 0.0); }
	else if (is_climby) { VERTEX = vertical_wave_displacement(VERTEX, TIME*1.5, 1.0, 0.0);
						  VERTEX = rot_displacement(VERTEX, TIME, anim_speed); }
	else if (!is_wavy) { VERTEX = rot_displacement(VERTEX, TIME, anim_speed); }
	VERTEX = squish_displacement(VERTEX, TIME);
	
	if (is_dying && death_type == 1) {
		VERTEX = vertical_wave_displacement(VERTEX, TIME*1.5, 5.0, 0.0);
	}
	// VERY WEIRD EFFECT:
	//float x = UV.x - mod(UV.x, TEXTURE_PIXEL_SIZE.x);
	//float wave = x + cos(1.0 * PI * TIME + 10.0 * x);
	//VERTEX.y -= pow( VERTEX.y, 3.0 ) * 0.02 * 2.0 * wave;
}

const float amplitude = 8.0;
const float frequency = 15.0;

uniform vec2 gt;

void fragment() {
	vec2 uv = UV;
	
	if (is_wavy) {
		uv += vec2(amplitude * 0.001 * cos(anim_speed*0.5 * TIME + frequency * UV.y), 0.0);
		COLOR = texture(TEXTURE, uv);
	}
	
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
	
	
	if (uv.x <= mod(frame, columns)/columns || uv.x >= (mod(frame, columns)+1.)/columns) { COLOR.a = 0.0;}
	if (uv.y <= mod(floor(frame/columns), rows)/rows || uv.y >= (mod(floor(frame/columns), rows)+1.)/rows) { COLOR.a = 0.0;}
}