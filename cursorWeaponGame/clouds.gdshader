shader_type canvas_item;
render_mode unshaded; // optional

//uniform vec2 direction;
//uniform float speed;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


void fragment() {
	vec2 uv = UV;
	float speed = 0.01;
	uv.x += TIME * speed * 0.9;
	uv.y += TIME * speed * 0.1;
	
	float noise1 = noise(uv) * 0.25;
	float noise2 = noise(2.0*uv) * 0.60;
	float noise3 = noise(4.0*uv) * 0.25;
	float noise4 = noise(5.0*uv) * 0.25;
	float noise5 = noise(20.0*uv) * 0.1;
	
	float all_noise = noise1+noise2+noise3+noise4+noise5;
	
	float shadowStrength = smoothstep(0.7, 0.45, all_noise) * 0.35;
	vec4 shadowColor = texture(screen_texture, SCREEN_UV) * (1.0 - shadowStrength);
	vec3 ambientLightColor = vec3(1.0, 0.5, 0.3) * 0.6;
	shadowColor.rgb = mix(shadowColor.rgb, ambientLightColor, shadowStrength);
	COLOR = shadowColor;
}
