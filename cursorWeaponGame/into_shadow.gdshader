shader_type canvas_item;


void fragment() {
	vec3 ambientLightColor = vec3(1.0, 0.5, 0.3) * 0.6;
	
	COLOR.rgb *= 0.0;
	COLOR.a *= 77./255.;
	COLOR.rgb = mix(COLOR.rgb, ambientLightColor, COLOR.a);
	
}