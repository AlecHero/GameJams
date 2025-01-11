// Original by @ENDESGA at https://www.shadertoy.com/view/dlKyWw
// splat-field forked from https://www.shadertoy.com/view/clGyWm

shader_type canvas_item;

uniform float timescale = 0.2; 
uniform float hScrollSpeedFactor = 1.; 
uniform float vScrollSpeedFactor = 1.;
uniform float entropyFactor = 1.; 
uniform float sharpness = 4.; 

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec3 hash(vec3 p)
{
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5,183.3,246.1)), dot(p, vec3(113.5, 271.9, 124.6)));
    p = fract(sin(p) * 43758.5453123);
    return p;
}

float shard_noise(in vec3 p, in float _sharpness) {
    vec3 ip = floor(p);
    vec3 fp = fract(p);

    float v = 0., t = 0.;
    for (int z = -1; z <= 1; z++) {
        for (int y = -1; y <= 1; y++) {
            for (int x = -1; x <= 1; x++) {
                vec3 o = vec3(float(x), float(y), float(z));
                vec3 io = ip + o;
                vec3 h = hash(io);
                vec3 r = fp - (o + h);

                float w = exp2(-TAU*dot(r, r));
                // tanh deconstruction and optimization by @Xor
                float s = _sharpness * dot(r, hash(io + vec3(11, 31, 47)) - 0.5);
                v += w * s*inversesqrt(1.0+s*s);
                t += w;
            }
        }
    }
    return ((v / t) * .5) + .5;
}

float s2noise( in vec2 _uv, int detail ) {
    vec3 uv = vec3(_uv.x + TIME*0.2, _uv.y + TIME*0.2, TIME*0.1);
	
	float noise = 0.0;
	for(float i = 1.0; i < float(detail+1); i++) {
		noise = noise + shard_noise(pow(2.,i+1.) * uv,sharpness) * pow(1./2.,i);
	}
    return noise;
}

void fragment() {
    COLOR.rgb = vec3(s2noise(UV, 3));
}