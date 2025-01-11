shader_type canvas_item;

uniform float anim_speed = 10.0;
uniform float squish_amount = 0.0;
uniform float alpha = 1.0;

group_uniforms Slice;
uniform float angle = 0.0; // 0 - PI
uniform float t : hint_range(-1, 1) = 0.0;
uniform float spread : hint_range(0, 90) = 45.0;
group_uniforms;

group_uniforms Spritesheet;
uniform float columns;
uniform float rows;
uniform vec2 frame_coords;
uniform vec2 frame_size;
group_uniforms;

bool is_current_frame( vec2 uv ) {
	float i = floor(frame_coords.x);
	float j = floor(frame_coords.y);
	bool inside_x = (i/columns) < uv.x && uv.x <= ((i+1.)/columns);
	bool inside_y = (j/rows)    < uv.y && uv.y <= ((j+1.)/rows);
	return (inside_x && inside_y);
}

vec2 rotated(vec2 point, float theta) { return mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta))) * point; }

uniform float amplitude;
uniform float frequency;
const bool transverse_wave = true; // transverse waves | longitudinal waves
vec2 wave_displacement(vec2 pos, float time, float amp, float freq) {
	if (transverse_wave) { return pos + vec2(amp * sin(pos.y * freq + TIME * anim_speed), 0.0); }
	else                 { return pos + vec2(amp * sin(pos.x * freq + TIME * anim_speed), 0.0); }
}

vec2 squish_displacement(vec2 vertex) {
	vertex -= floor(frame_coords) * frame_size;
	vertex *= vec2(1.+squish_amount, 1.-squish_amount);
	vertex += floor(frame_coords) * frame_size;
	return vertex;
}

const bool yes = true;

void vertex() {
	//VERTEX = wave_displacement(VERTEX.yx, TIME).yx;
	//VERTEX = rotated(VERTEX, sin(TIME * anim_speed) * radians(spread));
	//VERTEX = squish_displacement(VERTEX);
	if (yes) { VERTEX.x += 1.; }
}

void fragment() {
	vec2 uv = UV;
	//bool is_frame = is_current_frame(uv);
	//uv = wave_displacement(uv.yx, TIME, amplitude*0.001, frequency).yx;
	//if (yes) { uv *= (1.+2./18.); }
	COLOR = texture(TEXTURE, uv);
}

// slice:
	//vec2 frame_center = vec2(
		//(2.0*(mod(frame, columns)+1.)-1.) / (columns*2.),
		//(2.0*(mod(floor(frame/columns), rows)+1.)-1.) / (rows*2.)
	//);
	//uv = (uv-frame_center) * expansion + frame_center;
	//
	//vec2 dist = vec2(t)*2.0/(columns*rows)*vec2(cos(angle),sin(angle));
	//bool is_top = (uv.x-frame_center.x)*sin(angle) - (uv.y-frame_center.y)*cos(angle) > 0.0;
	//if (is_top) { uv += dist; }
	//else { uv -= dist; }
	//
	//if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) { COLOR = vec4(0.0); }
	//else { COLOR = texture(TEXTURE, uv); }
	//
	//COLOR.a *= 1.0-t;