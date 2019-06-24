shader_type spatial;
render_mode world_vertex_coords;
//render_mode cull_disabled;
//render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

/* Reference:
https://medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a
https://catlikecoding.com/unity/tutorials/advanced-rendering/triplanar-mapping/
https://blog.selfshadow.com/publications/blending-in-detail/index.html
https://discourse.selfshadow.com/t/blending-in-detail/21/17

*/

/*
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;


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



vec3 unpack_normal(vec4 packed) {
	// If shader GLES/mobile
	//return packed.xyz * 2.0 - 1.0;
	
	vec3 n;
	n.xy = packed.xy*2.0-1.0;
	n.z = sqrt(1. - n.x*n.x - n.y*n.y);
	n.xy *= normal_strength;
	return n;  // return -n matches output of above
}

// Reoriented Normal Mapping for Unity3d
// http://discourse.selfshadow.com/t/blending-in-detail/21/18
vec3 rnmBlendUnpacked(vec3 n1, vec3 n2)
{
    n1 += vec3( 0,  0, 1);
    n2 *= vec3(-1, -1, 1);
    return n1*dot(n1, n2)/n1.z - n2;
}




void vertex() {
	v_world_pos = VERTEX;
	v_world_normal = NORMAL;
}




void fragment() {

	/*************************
	*** Get Blend Mask   
	**************************/
		
	// Get absolute value of world normal, as may be negative. Raise it to the power of blend sharpness between the planar maps
	vec3 blend_mask = pow(abs(v_world_normal), vec3(triplanar_blend_sharpness,triplanar_blend_sharpness,triplanar_blend_sharpness));
	
	// Total weights must sum to 1, so normalize via division by total
	blend_mask = blend_mask / (blend_mask.x + blend_mask.y + blend_mask.z);


	/****************************************
	*** Create UVs w/ Scale and offsets 
	*****************************************/

	// Create UVs for each axis based on world position of the fragment and apply texture scale
	vec2 UVx = v_world_pos.yz / texture_scale;
	vec2 UVy = v_world_pos.xz / texture_scale;
	vec2 UVz = v_world_pos.xy / texture_scale;

	
	// Fix mirrored mapping (optional)
	/*
	if(v_world_normal.x < 0.) UVx.x = -UVx.x;
	if(v_world_normal.y < 0.) UVy.x = -UVy.x;
	if(v_world_normal.z < 0.) UVz.x = -UVz.x;
	*/
	
	// Offset UVs (optional)
	/*
	UVx.y += 0.5;
	UVy.x += 0.5;
	UVz.x += 0.5;
	*/

	/********************************
	*** Project Albedo Texture 
	*********************************/
	
	// Project texture onto each axis
	vec4 xProj = texture(side_albedo, UVx);
	vec4 yProj = texture(side_albedo, UVy);
	vec4 zProj = texture(side_albedo, UVz);

	// Color axis if parameter is checked
	if(show_normals) {
		xProj *= vec4(1.,0.,0.,1.);
		yProj *= vec4(0.,1.,0.,1.);
		zProj *= vec4(0.,0.,1.,1.);
	}	

	// Finally modulate the contribution of each mapping by it's weight	
	//ALBEDO = (xProj*blend_mask.x + yProj*blend_mask.y + zProj*blend_mask.z).rgb;
	//ALBEDO = blend_mask;  // Show blending w/o texture


	/********************************
	*** Calculate Normalmap 
	*********************************/
	
	// Tangent space normal maps
	vec3 tangent_normalX = unpack_normal(texture(side_normalmap, UVx));
	vec3 tangent_normalY = unpack_normal(texture(side_normalmap, UVy));
	vec3 tangent_normalZ = unpack_normal(texture(side_normalmap, UVz));


	// Swizzle tangent normals to match world orientation and triblend
	vec3 world_normal = normalize(
    	-tangent_normalX.zyx * blend_mask.x +
    	tangent_normalY.xzy * blend_mask.y +
    	tangent_normalZ * blend_mask.z
    	);
	
	//ALBEDO = world_normal;	// Check colors appear on correct faces

	// Fix mirrored mapping (optional, if donw for albedo)
	/*
	if(v_world_normal.x < 0.) UVx.x = -UVx.x;
	if(v_world_normal.y < 0.) UVy.x = -UVy.x;
	if(v_world_normal.z < 0.) UVz.x = -UVz.x;
	*/



	
	//Naive	
	// Get the sign (-1 or 1) of the surface normal
	//vec3 axisSign = sign(v_world_normal);
	// Flip tangent normal z to account for surface normal facing
	//tangent_normalX.z *= axisSign.x; 	tangent_normalY.z *= axisSign.y; 	tangent_normalZ.z *= axisSign.z;


	// Whiteout
	// Swizzle world normals into tangent space and apply Whiteout blend
	/*tangent_normalX = vec3(tangent_normalX.xy + v_world_normal.zy, abs(tangent_normalX.z) * v_world_normal.x);
	tangent_normalY = vec3(tangent_normalY.xy + v_world_normal.xz, abs(tangent_normalY.z) * v_world_normal.y);
	tangent_normalZ = vec3(tangent_normalZ.xy + v_world_normal.xy, abs(tangent_normalZ.z) * v_world_normal.z); */
	    

	// Swizzle tangent normals to match world orientation and triblend
	/*worldNormal = normalize(
    	tangent_normalX.zyx * blend_mask.x +
    	tangent_normalY.xzy * blend_mask.y +
    	tangent_normalZ.xyz * blend_mask.z
    	);
	*/
	
	/*
	// GPU Gems 3: Swizzle tangemt normals into world space and zero out "z"
	vec3 normalX = vec3(0.0, tangent_normalX.yx);
	vec3 normalY = vec3(tangent_normalY.x, 0.0, tangent_normalY.y);
	vec3 normalZ = vec3(tangent_normalZ.xy, 0.0);

	// Triblend normals and add to world normal
	vec3 worldNormal = normalize(
    	normalX.zyx * blending.x +
    	normalY.xzy * blending.y +
    	normalZ.xyz * blending.z +
    	v_world_normal
    );
	*/
	
	//NORMAL = (INV_CAMERA_MATRIX * (WORLD_MATRIX * vec4(world_normal, 0.0))).xyz;
	//NORMAL = (INV_CAMERA_MATRIX * (vec4(world_normal, 0.0))).xyz;
	//BINORMAL = (INV_CAMERA_MATRIX * (vec4(world_normal, 0.0))).xyz;
	//TANGENT = (INV_CAMERA_MATRIX * (vec4(world_normal, 0.0))).xyz;
	NORMALMAP= (xProj*blend_mask.x + yProj*blend_mask.y + zProj*blend_mask.z).rgb;

	//NORMAL = (INV_CAMERA_MATRIX * (vec4(NORMAL, 0.0))).xyz;
	
	//generate tangent and binormal in world space
    TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
    TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
    TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
    TANGENT = normalize(TANGENT);

    BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
    BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
    BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
    BINORMAL = normalize(BINORMAL);

	
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

	
	//float roughness_tex = dot(texture(side_normalmap,v_world_pos),roughness_texture_channel);
	//ROUGHNESS = roughness_tex * roughness;
	//ROUGHNESS = texture_triplanar(side_albedo, v_world_pos, triblend).rgb;

	

	
}





