shader_type canvas_item;

uniform float anim_speed = 7;
uniform float squish_amount = 0.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float rand  : hint_range(0.0, 1.0) = 0.5;
uniform float hue_factor : hint_range(0.0, 5.0) = 1.0;
uniform float turn_factor : hint_range(0.0, 1.0) = 0.4;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const vec4 drop_shadow_color = vec4(vec3(0), 0.3);
const float shadow_radius = 0.1;
uniform float shadow_angle : hint_range(0.0, 6.28, 0.1) = 3.14;
uniform vec2 offset = vec2(0.0);
uniform bool has_shadow = true;

vec2 rotated(vec2 point, float theta) {
	mat2 rot = mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)));
	return rot * point;
}

vec2 rot_displacement(vec2 pos, float time, float speed) {
	float theta = sin(speed * time) * 0.25 * turn_factor;
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
	VERTEX = rot_displacement(VERTEX, TIME+rand*100.0, anim_speed);
	VERTEX = squish_displacement(VERTEX, TIME);
	VERTEX *= float(1) + float(2) * abs(shadow_radius); // for shadow handling
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


vec3 rgb2hsl(vec3 color) {
    float max_color = max(max(color.r, color.g), color.b);
    float min_color = min(min(color.r, color.g), color.b);
    float delta = max_color - min_color;

    float lightness = (max_color + min_color) / 2.0;
    float hue = 0.0;
    float sat = 0.0;  // Rinomina la saturazione locale in 'sat'

    if (delta != 0.0) {
        sat = (lightness < 0.5) ? (delta / (max_color + min_color)) : (delta / (2.0 - max_color - min_color));
        
        if (max_color == color.r) {
            hue = (color.g - color.b) / delta + (color.g < color.b ? 6.0 : 0.0);
        } else if (max_color == color.g) {
            hue = (color.b - color.r) / delta + 2.0;
        } else {
            hue = (color.r - color.g) / delta + 4.0;
        }

        hue /= 6.0;
    }

    return vec3(hue, sat, lightness);
}

// Funzione per convertire da HSL a RGB
vec3 hsl2rgb(vec3 hsl) {
    float hue = hsl.x;
    float sat = hsl.y;  // Usa 'sat' invece di 'saturation'
    float lightness = hsl.z;

    float chroma = (1.0 - abs(2.0 * lightness - 1.0)) * sat;
    float h = hue * 6.0;
    float x = chroma * (1.0 - abs(mod(h, 2.0) - 1.0));

    vec3 result;

    if (h < 1.0) {
        result = vec3(chroma, x, 0.0);
    } else if (h < 2.0) {
        result = vec3(x, chroma, 0.0);
    } else if (h < 3.0) {
        result = vec3(0.0, chroma, x);
    } else if (h < 4.0) {
        result = vec3(0.0, x, chroma);
    } else if (h < 5.0) {
        result = vec3(x, 0.0, chroma);
    } else {
        result = vec3(chroma, 0.0, x);
    }

    float m = lightness - chroma / 2.0;
    return result + vec3(m, m, m);
}


void fragment()  {
	if (has_shadow) {
		vec2 uv2 = UV * float(float(1) + float(2) * abs(shadow_radius)) - vec2(abs(shadow_radius));
		vec4 original_color = sample_texture(TEXTURE, uv2);
		vec2 unit_circle = vec2(cos(shadow_angle+PI/2.0), sin(shadow_angle+PI/2.0));
		unit_circle += offset;
		
		vec4 shadow_color = vec4(drop_shadow_color.rgb, sample_texture(TEXTURE, uv2 - unit_circle * shadow_radius).a * drop_shadow_color.a);
		vec3 ambientLightColor = vec3(1.0, 0.5, 0.3) * 0.6;
		shadow_color.rgb = mix(shadow_color.rgb, ambientLightColor, shadow_color.a);
		
		if (shadow_color.a > float(0)) {
			COLOR = mixcolor(shadow_color, original_color);
		} else {
			COLOR = original_color;
		}
	} else {
		vec2 uv2 = UV * float(float(1) + float(2) * abs(shadow_radius)) - vec2(abs(shadow_radius));
		COLOR = sample_texture(TEXTURE, uv2);
	}
	
	vec3 hsl = rgb2hsl(COLOR.rgb);
	hsl.x += hue_factor * (rand-0.5);
	COLOR.rgb = hsl2rgb(hsl);
	COLOR.a *= alpha;
}