shader_type canvas_item;

vec4 mixcolor(vec4 colA, vec4 colB)  {
	return vec4((colA.rgb + colB.a * (colB.rgb - colA.rgb)), colA.a + colB.a);
}

vec4 sample_texture(sampler2D texture, vec2 uv)  {
	if ((uv.x < 0.0 || uv.x > 1.0) || (uv.y < 0.5 || uv.y > 1.0))  {
		return vec4(0.0);
	} else {
		return texture(texture, uv);
	}
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	const float r = 0.4;
	const float e = 0.2;
	float value = smoothstep(r, r-e, length(uv));

	vec4 shadow_color = vec4(vec3(0.0), value) * 0.4;
	vec3 ambientLightColor = vec3(1.0, 0.5, 0.3) * 0.6;
	shadow_color.rgb = mix(shadow_color.rgb, ambientLightColor, shadow_color.a);
	vec4 original_color = sample_texture(TEXTURE, uv);

	if (shadow_color.a > float(0)) {
		COLOR = mixcolor(shadow_color, original_color);
	} else {
		COLOR = original_color;
	}
}