shader_type canvas_item;

uniform float amount : hint_range(0, 1);
uniform float scale : hint_range(0, 12);
uniform float darkscale : hint_range(0, 1);

void fragment(){
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, amount * scale);
	COLOR.rgb *= 1f - (0.1 * darkscale);
}