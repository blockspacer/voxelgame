shader_type spatial;
//render_mode cull_disabled;

//render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

/* Reference:
https://medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a

*/

uniform float roughness : hint_range(0,1);
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;

/*
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
*/

uniform sampler2D top_albedo : hint_albedo;
uniform sampler2D top_normalmap : hint_normal;

uniform sampler2D side_albedo : hint_albedo;
uniform sampler2D side_normalmap : hint_normal;

uniform float normal_strength : hint_range(0.001, 5.0) = 1.;

//uniform float bottom_ao : hint_range(0.0, 1.0);
//uniform float texture_scale = 1.;
//uniform float triplanar_blend_sharpness = 1.;

varying vec3 v_world_pos;
varying vec3 v_world_normal;


vec3 get_triplanar_blend(vec3 world_normal) {
	vec3 blending = abs(world_normal);
	blending = normalize(max(blending, vec3(0.00001))); // Force weights to sum to 1.0
	float b = blending.x + blending.y + blending.z;
	return blending / vec3(b, b, b);
}

vec4 texture_triplanar(sampler2D tex, vec3 world_pos, vec3 blend) {
	vec4 xaxis = texture(tex, world_pos.yz);
	vec4 yaxis = texture(tex, world_pos.xz);
	vec4 zaxis = texture(tex, world_pos.xy);
	// blend the results of the 3 planar projections.
	return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}


vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	n.xy /= normal_strength;
	return -n;
}

// Reoriented Normal Mapping for Unity3d
// http://discourse.selfshadow.com/t/blending-in-detail/21/18
vec3 rnmBlendUnpacked(vec3 n1, vec3 n2)
{
    n1 += vec3( 0,  0, 1);
    n2 *= vec3(-1, -1, 1);
    return n1*dot(n1, n2)/n1.z - n2;
}

vec3 get_normal(mat4 cam_matrix, mat4 world_matrix, vec3 blend) {
	// Triplanar uvs
	vec2 uvX = v_world_pos.zy; // x facing plane  // yz?
	vec2 uvY = v_world_pos.xz; // y facing plane
	vec2 uvZ = v_world_pos.xy; // z facing plane
	
	// Tangent space normal maps
	vec3 tnormalX = unpack_normal(texture(side_normalmap, uvX));
	vec3 tnormalY = unpack_normal(texture(side_normalmap, uvY));
	vec3 tnormalZ = unpack_normal(texture(side_normalmap, uvZ));

	//Naive	
	// Get the sign (-1 or 1) of the surface normal
	//vec3 axisSign = sign(v_world_normal);
	// Flip tangent normal z to account for surface normal facing
	//tnormalX.z *= axisSign.x; 	tnormalY.z *= axisSign.y; 	tnormalZ.z *= axisSign.z;


	// Whiteout
	// Swizzle world normals into tangent space and apply Whiteout blend
	/*tnormalX = vec3(tnormalX.xy + v_world_normal.zy, abs(tnormalX.z) * v_world_normal.x);
	tnormalY = vec3(tnormalY.xy + v_world_normal.xz, abs(tnormalY.z) * v_world_normal.y);
	tnormalZ = vec3(tnormalZ.xy + v_world_normal.xy, abs(tnormalZ.z) * v_world_normal.z); */
	    

	// Swizzle tangent normals to match world orientation and triblend
	vec3 worldNormal = normalize(
    	tnormalX.zyx * blend.x +
    	tnormalY.xzy * blend.y +
    	tnormalZ.xyz * blend.z
    	);
	
	
	/*
	// GPU Gems 3: Swizzle tangemt normals into world space and zero out "z"
	vec3 normalX = vec3(0.0, tnormalX.yx);
	vec3 normalY = vec3(tnormalY.x, 0.0, tnormalY.y);
	vec3 normalZ = vec3(tnormalZ.xy, 0.0);

	// Triblend normals and add to world normal
	vec3 worldNormal = normalize(
    	normalX.zyx * blending.x +
    	normalY.xzy * blending.y +
    	normalZ.xyz * blending.z +
    	v_world_normal
    );
	*/
	
	return (cam_matrix * (world_matrix * vec4(worldNormal, 0.0))).xyz;
	
}



void vertex() {
	v_world_pos = VERTEX;
	v_world_normal = NORMAL;

}



void fragment() {
	vec3 triblend = get_triplanar_blend(v_world_normal);
	ALBEDO = texture_triplanar(side_albedo, v_world_pos, triblend).rgb;

	//NORMAL = get_normal(INV_CAMERA_MATRIX, WORLD_MATRIX, triblend);
	
	//float roughness_tex = dot(texture(side_normalmap,v_world_pos),roughness_texture_channel);
	//ROUGHNESS = roughness_tex * roughness;
	//ROUGHNESS = texture_triplanar(side_albedo, v_world_pos, triblend).rgb;

	

	
}





