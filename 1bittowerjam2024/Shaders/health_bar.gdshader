shader_type canvas_item;

uniform float alpha : hint_range(0, 1) = 1;
uniform float progress : hint_range(0, 1) = 1;
//uniform float grille_size = 1.0;
uniform float grille_amount : hint_range(0, 40, 1) = 5.0;

vec3 grille(vec2 uv, vec4 color){
	float unit = PI / 3.0;
	float scale = 2.0 * unit * grille_amount;
	float r1 = smoothstep(0.5, 0.8, cos(uv.x*scale - unit));
	float r2 = smoothstep(0.5, 0.8, cos(uv.x*scale + unit));
	float r3 = smoothstep(0.5, 0.8, cos(uv.x*scale + 3.0*unit));
	float grille_size = max(1.0, grille_amount / 3.0);
	return mix(color.rgb, vec3(r1+r2+r3), grille_size);
}

void fragment() {
	if (COLOR.rgb == vec3(1., 1., 1.)) {
		COLOR.rgb = round(grille(UV, COLOR));
		if (UV.x > progress) { COLOR.rgb = vec3(0.0); }
		//COLOR.gb = vec2(0.0); // make RED
	}
	COLOR.a *= alpha;
}