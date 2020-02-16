shader_type canvas_item;

uniform sampler2D displace : hint_albedo;
uniform float dispAmt : hint_range(0,0.1);
uniform float abX: hint_range(0,0.1);
uniform float abY: hint_range(0,0.1);
uniform float disp_size: hint_range(0.1,1);


void fragment() {
	vec4 disp = texture(displace, SCREEN_UV * disp_size);
	vec2 newUV = SCREEN_UV + disp.xy * dispAmt;
	
	if (texture(TEXTURE, UV).a > 0.0) {
		COLOR.r = texture(SCREEN_TEXTURE, newUV - vec2(abX,abY)).r;
		COLOR.g = texture(SCREEN_TEXTURE, newUV).g;
		COLOR.b = texture(SCREEN_TEXTURE, newUV + vec2(abX,abY)).b;
		COLOR.a = texture(SCREEN_TEXTURE, newUV).a;
	} else {
		COLOR.a = 0.0
	}
}