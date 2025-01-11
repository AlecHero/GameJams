shader_type canvas_item;

group_uniforms Spritesheet;
uniform float columns;
uniform float rows;
uniform vec2 frame_coords;
group_uniforms;

bool is_current_frame( vec2 uv ) {
	float i = floor(frame_coords.x);
	float j = floor(frame_coords.y);
	bool inside_x = (i/columns) < uv.x && uv.x <= ((i+1.)/columns);
	bool inside_y = (j/rows)    < uv.y && uv.y <= ((j+1.)/rows);
	return (inside_x && inside_y);
}

void fragment() {
	vec2 uv = UV;
	if (!is_current_frame(uv)) { COLOR.a = 0.0; }
}