shader_type spatial;
render_mode diffuse_burley;

uniform bool		B_use_albedo = true;
uniform vec4 		B_albedo_tint : hint_color = vec4(1., 1., 1., 1.);
uniform sampler2D 	B_albedo_map : hint_albedo;
uniform bool		B_use_normal = true;
uniform sampler2D 	B_normal_map : hint_normal;
uniform float 		B_normal_strength : hint_range(-16., 16.0) = 1.;
uniform bool		B_use_ao = true;
uniform float 		B_ao_strength : hint_range(-1., 1.0) = 1.; 
uniform vec4 		B_ao_texture_channel = vec4(1., 0., 0., 0.);		// Only use one channel: Red, Green, Blue, Alpha
uniform sampler2D 	B_ao_map : hint_white;

uniform float 		B_tri_blend_sharpness : hint_range(0.001, 100.0) = 50.;
uniform int 		B_uv_tile : hint_range(1, 8) = 1;
uniform vec3 		B_uv_offset;

varying vec3 		uv_triplanar_pos;
varying vec3 		uv_power_normal;


void vertex() {
    TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
    TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
    TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
    TANGENT = normalize(TANGENT);
    BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
    BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
    BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
    BINORMAL = normalize(BINORMAL);
    uv_power_normal=pow(abs(NORMAL),vec3(B_tri_blend_sharpness));
    uv_power_normal/=dot(uv_power_normal,vec3(1.0));
    uv_triplanar_pos = VERTEX * float(B_uv_tile) / (16.) + B_uv_offset;			//On VoxelTerrain 16 is 100% size for 1k textures, so uv_scale -> tiles as multiples of 16. 
																				//How about 2k-8k textures???
	uv_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
        vec4 samp=vec4(0.0);
        samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
        samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
        samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
        return samp;
}


void fragment() {

	if(B_use_albedo) {
		vec4 albedo_tex = triplanar_texture(B_albedo_map,uv_power_normal,uv_triplanar_pos);	
		ALBEDO = B_albedo_tint.rgb * albedo_tex.rgb;
	}
	
	if(B_use_normal) {
		NORMALMAP = triplanar_texture(B_normal_map,uv_power_normal,uv_triplanar_pos).rgb;
		NORMALMAP_DEPTH = B_normal_strength;
	}
	
	if(B_use_ao) {
		AO = dot(triplanar_texture(B_ao_map,uv_power_normal,uv_triplanar_pos),B_ao_texture_channel);
		AO_LIGHT_AFFECT = B_ao_strength;
	}
}





