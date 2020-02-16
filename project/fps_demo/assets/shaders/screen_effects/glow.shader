shader_type canvas_item;
render_mode blend_add;

uniform float opacity = 0.5;

void fragment() {
	
	vec3 texScreen = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float texSum = (texScreen.r + texScreen.g + texScreen.b) / 3.0;
	
	COLOR.a = clamp(1.0 - distance(UV, vec2(0.5)) * 2.0, 0.0, 1.0) * opacity;
}