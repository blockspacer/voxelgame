shader_type spatial;
//render_mode cull_disabled;
//render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

/* Reference:
https://medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a
https://catlikecoding.com/unity/tutorials/advanced-rendering/triplanar-mapping/
*/

/*
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
*/

uniform sampler2D top_albedo : hint_albedo;
uniform sampler2D top_normalmap : hint_normal;
uniform sampler2D top_ao : hint_white;

uniform sampler2D side_albedo : hint_albedo;
uniform sampler2D side_normalmap : hint_normal;
uniform sampler2D side_ao : hint_white;

uniform bool show_normals = false;
uniform float normal_strength : hint_range(0.001, 5.0) = 1.;
uniform float texture_scale : hint_range(0.1, 10.0) = 1.;
uniform float triplanar_blend_sharpness : hint_range(2., 100.0) = 2.;

varying vec3 v_world_pos;
varying vec3 v_world_normal;




void vertex() {
	v_world_pos = VERTEX;
	v_world_normal = NORMAL;

}

//Mask off everything but the texture aligned with the normal
vec3 get_triplanar_blend(vec3 world_normal) {
	vec3 blending = abs(world_normal);
	blending = normalize(max(blending, vec3(0.00001))); //Force weights to sum to 1.0 (max necessary?)
	float b = blending.x + blending.y + blending.z;
	return blending / vec3(b, b, b);
}

// Project the textures on each axis
vec4 texture_triplanar(sampler2D tex, vec3 world_pos, vec3 blend) {
	vec4 xProj = texture(tex, world_pos.yz);	
	vec4 yProj = texture(tex, world_pos.xz);	
	vec4 zProj = texture(tex, world_pos.xy);	
	return xProj*blend.x + yProj*blend.y + zProj*blend.z;	
}

void fragment() {
	
	//vec3 triblend = get_triplanar_blend(v_world_normal);
	//ALBEDO = texture_triplanar(side_albedo, v_world_pos, triblend).rgb;

	// Create UVs for each axis based on world position of the fragment
	vec2 xUV = v_world_pos.yz / texture_scale;
	vec2 yUV = v_world_pos.xz / texture_scale;
	vec2 zUV = v_world_pos.xy / texture_scale;
	
	// Fix mirrored mapping
	if(v_world_normal.x < 0.) xUV.x = -xUV.x;
	if(v_world_normal.y < 0.) yUV.x = -yUV.x;
	if(v_world_normal.z < 0.) zUV.x = -zUV.x;

	// Offset UVs
	//xUV.y += 0.5;
	//zUV.x += 0.5;
	
	// Sample albedo based on these UV sets
	vec4 xProj = texture(side_albedo, xUV);
	vec4 yProj = texture(side_albedo, yUV);
	vec4 zProj = texture(side_albedo, zUV);

	if(show_normals) {
		xProj *= vec4(1.,0.,0.,1.);
		yProj *= vec4(0.,1.,0.,1.);
		zProj *= vec4(0.,0.,1.,1.);
	}	

	// Get blends
	
	// Get absolute value of world normal, as may be negative. Raise it to the power of blend sharpness between the planar maps
	vec3 blendWeight = pow(abs(v_world_normal), vec3(triplanar_blend_sharpness,triplanar_blend_sharpness,triplanar_blend_sharpness));

	//? blending = normalize(max(blending, vec3(0.00001))); //Force weights to sum to 1.0 (max necessary?)
	
	// Total weights has to sum 1, so normalize via division by total
	blendWeight = blendWeight / (blendWeight.x + blendWeight.y + blendWeight.z);
		
	// Finally modulate the contribution of each mapping by it's weight	
	ALBEDO = (xProj*blendWeight.x + yProj*blendWeight.y + zProj*blendWeight.z).rgb;
	//ALBEDO = blendWeight;

	// No blending at all, cut off everything else except that face 
	/*
	vec3 v = abs(v_world_normal);
	if(v.x < .575) v.x=0.;
	if(v.y < .575) v.y=0.;
	if(v.z < .575) v.z=0.;
	ALBEDO = v;
	*/
	

	/*
	if(v_world_normal.g>0.8)		ALBEDO = vec3(0,0.2*v_world_normal.g,0.03); 
	else if (v_world_normal.g>0.5)	ALBEDO = vec3(0.2*v_world_normal.g,0.1*v_world_normal.g,0); 
	else 							ALBEDO = vec3(0.01+0.2*v_world_normal.g,0.005 + 0.1*v_world_normal.g,0); 
		//v_world_pos; //vec3(1,0,0);
	*/
	
	//AO = v_world_normal.g;
	//NORMAL = get_normal(INV_CAMERA_MATRIX, WORLD_MATRIX, triblend);
	
	
}





