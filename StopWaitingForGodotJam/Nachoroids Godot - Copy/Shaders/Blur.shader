shader_type canvas_item;
uniform float blur : hint_range(1, 20, 1) = 5;

//https://www.reddit.com/r/godot/comments/hu1dkc/how_to_make_2dblurshader_using_pixels_as_blur_unit/
//^^ Box Blur

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur / 10.0);
}