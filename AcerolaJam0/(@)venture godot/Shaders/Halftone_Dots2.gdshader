shader_type canvas_item;
uniform float aspect_ratio = 1.667;
// Halftone Shader
// Alexander Wittrup 06/06/2022
// 2D simplex noise by Ian McEwan, distributed under the MIT license.
// All other code is original but heavily inspired and occasionally
// directly converted from Stefan Gustavson's WebGL halftone shader demo:
// https://weber.itn.liu.se/~stegu/webglshadertutorial/shadertutorial.html
// And some features are inspired by Mrmo Tarius' MRMO-Halftone shader for blender
// https://mrmotarius.itch.io/mrmo-halftone


vec3 permute(vec3 x) { return mod(((x * 34.0) + 1.0) * x, 289); }
float snoise(vec2 v) {
	// (3.0-sqrt(3.0))/6.0 , 0.5*(sqrt(3.0)-1.0)
	const vec4 CC = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
	// -1.0 + 2.0 * C.x , 1.0 / 41.0
	
	// First corner
	vec2 i = floor(v + dot(v, CC.yy) );
	vec2 x0 = v - i + dot(i, CC.xx);
	// Other corners
	vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec4 x12 = x0.xyxy + CC.xxzz;
	x12.xy -= i1;
	// Permutations
	i = mod(i, 289); // Avoid truncation effects in permutation
	vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
	vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m *= m; m *= m;
	// Gradients
	vec3 x = 2.0 * fract(p * CC.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 a0 = x - floor(x + 0.5);
	// Normalise gradients implicitly by scaling m
	m *= 1.792843 - 0.853735 * (a0 * a0 + h * h);
	// Compute final noise value at P
	vec3 g;
	g.x = a0.x * x0.x + h.x * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	
	return 130.0 * dot(m, g);
}

vec2 uv_translate(vec2 off, vec2 uv) {
	float z = 0.0;
	uv.x = uv.x + off.x - .5;
	uv.y = uv.y + off.y - .5;
	return uv;
}

vec2 rotate(vec2 uv, float r) {
	r = radians(r); //r *= (PI / 180.0); //Radians to degrees
	return uv * mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
}

uniform float contrast : hint_range(0, 3) = 1.0;
uniform bool grayscale = false;
vec4 img_texture(sampler2D tex, vec2 uv, vec2 px_size, vec2 offset) {
	vec4 image_texture = texture(tex, uv_translate(vec2(.5, .5) + offset, uv)); //Blurring and scaling
	image_texture.rgb = mix(vec3(0.5), image_texture.rgb, contrast); //Contrast
	if (grayscale) image_texture.rgb = vec3(.3 * image_texture.r + .6 * image_texture.g + .1 * image_texture.b);
	return image_texture;
}

uniform bool dynamic_halftone = true;
uniform bool dynamic_noise = true;
uniform float feather : hint_range(0.0, 1.5) = 0.15;
uniform float noise_ratio : hint_range(0.0, 1.0, 0.01) = 1.0;
float halftone(float value, float angle, vec2 uv) {
	if (dynamic_halftone) { uv = uv + TIME/5.0; }
	float dn = float(dynamic_noise) * TIME;
	float noise = snoise(0.2 * (uv + dn)) + snoise(2.0 * (uv + dn)) * 2.0 + snoise(4.0 * (uv -  dn)) * 0.8;
	float halftone_pattern = length(2.0 * fract(rotate(uv, angle)) - 1.0); //The halftone pattern
	return smoothstep(0.0, feather, value - halftone_pattern + min(0.05, (noise_ratio*0.1) * noise));
}

//Multiplicative blend mode
vec3 mul_blend(vec3 base, vec3 blend) { return max(base + blend - 1.0, 0.0); }

//Halftone settings
uniform float pattern_offset : hint_range(-0.1, 0.1, 0.0001) = 0.005;
uniform float fill : hint_range(0.0, 3.0) = 2;
uniform float frequency : hint_range(10., 1000., 1.0) = 200.0;
uniform float k_ratio : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform bool rich_black = false;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
//uniform sampler2D paper_texture; //For future optional paper-dents etc. idk how to do normals though
uniform vec4 paper_color : source_color = vec4(0.99, 0.93, 0.8, 1.0);
uniform vec4 C : source_color = vec4(.4, .85, .85, 1.0);
uniform vec4 M : source_color = vec4(.85, .25, .5, 1.0);
uniform vec4 Y : source_color = vec4(.85, .85, .2, 1.0);
uniform vec4 K : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float C_angle : hint_range(0, 360, 1.0) = 165;
uniform float M_angle : hint_range(0, 360, 1.0) = 45;
uniform float Y_angle : hint_range(0, 360, 1.0) = 90;
uniform float K_angle : hint_range(0, 360, 1.0) = 105;

void fragment() {
	vec2 uv = vec2(UV.x * aspect_ratio, UV.y) * frequency; // Corrects aspect ratio for non-square images
	
	vec4 cmyk;
	cmyk.r = 1.0 - img_texture(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE, vec2(pattern_offset/10., 0.0)).r;
	cmyk.g = 1.0 - img_texture(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE, vec2(0.0, pattern_offset/10.)).g;
	cmyk.b = 1.0 - img_texture(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE, vec2(-pattern_offset/10., -pattern_offset/10.)).b;
	cmyk.a = min(min(cmyk.r, cmyk.g), cmyk.b) * k_ratio;
	
	if (!(rich_black)) { cmyk.rgb = (cmyk.rgb - cmyk.a) / (1.0 - cmyk.a); } // CMY with K added on top
	cmyk = cmyk * fill;
	
	float paper_noise = snoise(0.7 * uv) + snoise(2.0 * uv);
	vec3 color = paper_color.rgb + 0.02 * paper_noise;
	color = mul_blend(color, 1.0 - (1.0 - C.rgb) * halftone(cmyk.r, C_angle, uv));
	color = mul_blend(color, 1.0 - (1.0 - M.rgb) * halftone(cmyk.g, M_angle, uv));
	color = mul_blend(color, 1.0 - (1.0 - Y.rgb) * halftone(cmyk.b, Y_angle, uv));
	color = mul_blend(color, 1.0 - (1.0 - K.rgb) * halftone(cmyk.a, K_angle, uv));
	COLOR.rgb = color;
}