shader_type canvas_item;

uniform float res = 0.25;
uniform int force = 4;
uniform float opacity = 0.75;
uniform bool disableShade = false;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (!disableShade) {
		if (col.r < 1.0) {
			for (int x = -force; x <= force; x++)
			for (int y = -force; y <= force; y++) {
				vec4 to_add = texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * res * vec2(float(x), float(y)));
				if (to_add.r > 0.5)
					to_add *= 2.0;
				col += to_add;
			}
			COLOR.rgb = texture(SCREEN_TEXTURE, SCREEN_UV).rgb * clamp(((col / float((force * 2 + 1) * (force * 2 + 1))).r + vec4( vec3(1.0 - opacity), 0.0).r), 0.0, 1.0);
		} else {
			COLOR.a = 0.0;
		}
	} else {
		if (col.r < 1.0) {
			COLOR.rgb = texture(SCREEN_TEXTURE, SCREEN_UV).rgb * (col.r + 1.0 - opacity);
			COLOR.a = col.a;
		}
		else
			COLOR.a = 0.0;
	}
}
