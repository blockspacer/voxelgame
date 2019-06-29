shader_type spatial;
render_mode diffuse_burley;
//,world_vertex_coords;

// A is the top texture
// B is the sides and bottom

uniform bool		A_albedo_enabled = true;
uniform vec4 		A_albedo_tint : hint_color = vec4(1., 1., 1., 1.);
uniform sampler2D 	A_albedo_map : hint_albedo;
uniform bool		A_normal_enabled = true;
uniform sampler2D 	A_normal_map : hint_normal;
uniform float 		A_normal_strength : hint_range(-16., 16.0) = 1.;
uniform bool		A_ao_enabled = true;
uniform float 		A_ao_strength : hint_range(-1., 1.0) = 1.; 
uniform vec4 		A_ao_texture_channel = vec4(1., 0., 0., 0.);		// Only use one channel: Red, Green, Blue, Alpha
uniform sampler2D 	A_ao_map : hint_white;
uniform float 		A_tri_blend_sharpness : hint_range(0.001, 50.0) = 50.;
uniform int 		A_uv_tiles : hint_range(1, 16) = 1;
uniform vec3 		A_uv_offset;

uniform bool		B_albedo_enabled = true;
uniform vec4 		B_albedo_tint : hint_color = vec4(1., 1., 1., 1.);
uniform sampler2D 	B_albedo_map : hint_albedo;
uniform bool		B_normal_enabled = true;
uniform sampler2D 	B_normal_map : hint_normal;
uniform float 		B_normal_strength : hint_range(-16., 16.0) = 1.;
uniform bool		B_ao_enabled = true;
uniform float 		B_ao_strength : hint_range(-1., 1.0) = 1.; 
uniform vec4 		B_ao_texture_channel = vec4(1., 0., 0., 0.);		// Only use one channel: Red, Green, Blue, Alpha
uniform sampler2D 	B_ao_map : hint_white;
uniform float 		B_tri_blend_sharpness : hint_range(0.001, 50.0) = 50.;
uniform int 		B_uv_tiles : hint_range(1, 16) = 1;
uniform vec3 		B_uv_offset;

uniform float 		AB_mix1 : hint_range(-10., 0.) = -6.;
uniform float 		AB_mix2 : hint_range(-50., 50.) = -10.;

uniform sampler2D	noise_texture : hint_white;


varying vec3 		A_uv_triplanar_pos;
varying vec3 		A_uv_power_normal;
varying vec3 		B_uv_triplanar_pos;
varying vec3 		B_uv_power_normal;
varying vec3 		v_world_normal;

varying vec4		l_vertex;
varying vec4		w_vertex;
varying float		v_rand;

float rand3D(in vec3 co){
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,144.7272))) * 43758.5453);
}	

void vertex() {
    TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
    TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
    TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
    TANGENT = normalize(TANGENT);
    BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
    BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
    BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
    BINORMAL = normalize(BINORMAL);

    A_uv_power_normal=pow(abs(NORMAL),vec3(A_tri_blend_sharpness));
    A_uv_power_normal/=dot(A_uv_power_normal,vec3(1.0));
    A_uv_triplanar_pos = VERTEX * float(A_uv_tiles) / (16.) + A_uv_offset;			//On VoxelTerrain 16 is 100% size, so uv_tile is multiples of 16. 
	A_uv_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
    B_uv_power_normal=pow(abs(NORMAL),vec3(B_tri_blend_sharpness));
    B_uv_power_normal/=dot(B_uv_power_normal,vec3(1.0));
    B_uv_triplanar_pos = VERTEX * float(B_uv_tiles) / (16.)  + B_uv_offset;
	B_uv_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	v_world_normal = NORMAL;	
	l_vertex = vec4(VERTEX,1.0);  //vec4(VIEW,1.0);// * INV_CAMERA_MATRIX;
	w_vertex = WORLD_MATRIX * vec4(VERTEX,1.0);
	v_rand = rand3D(VERTEX);
	//v_vertex = 	PROJECTION_MATRIX * CAMERA_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX,1.0);
}

	
vec4 detile_texture(sampler2D samp, vec2 pos) {
	//return v_vertex*vec4(pos, pos.y, pos.x);
	//return vec4(pos, pos.x, 1.); 
	//return v_vertex * rand3D(vec3(1.23,.56,.89)); 
	vec4 ret;
	//if(pos.x>.5 && pos.y > 0.5) 
	if(pos.y>0.) 
		ret = vec4(v_rand, 0.,0., 1.);
	if(pos.y<0.) 
		ret = vec4(0., v_rand, 0., 1.);
	return ret; //vec4(pos.x+v_rand,pos.y, 0., 1.);
	//return log(w_vertex);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
        vec4 samp=vec4(0.0);
        samp+= detile_texture(p_sampler,p_triplanar_pos.xy) * p_weights.z; //vec4(untiled_texture(p_sampler,p_triplanar_pos.xy), 1.) * p_weights.z;
        samp+= detile_texture(p_sampler,p_triplanar_pos.xz) * p_weights.y; //vec4(untiled_texture(p_sampler,p_triplanar_pos.xz), 1.) * p_weights.y;
        samp+= detile_texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x; //vec4(untiled_texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)), 1.) * p_weights.x;
        return samp;
}


void fragment() {

	
	// Get normal used for mixing top A and sides B
	vec3 normal = normalize(v_world_normal);
		
	// Calculate Albedo 
	
	vec3 A_albedo, B_albedo;
	if(A_albedo_enabled) {
		ALBEDO = A_albedo = A_albedo_tint.rgb * triplanar_texture(A_albedo_map,A_uv_power_normal,A_uv_triplanar_pos).rgb;
	}
	if(B_albedo_enabled) {
		ALBEDO = B_albedo = B_albedo_tint.rgb * triplanar_texture(B_albedo_map,B_uv_power_normal,B_uv_triplanar_pos).rgb;
	}
	if(A_albedo_enabled==true && B_albedo_enabled==true) {
		ALBEDO = mix(B_albedo, A_albedo, clamp(AB_mix1 + 10.*normal.y + AB_mix2*A_albedo.b , 0., 1.));
	}




	ALBEDO = detile_texture(A_albedo_map, vec2(1.,1.)).rgb;
	//ALBEDO = vec4(1.,1.,0.,1.).rgb;

/*

	// Calculate Ambient Occlusion
	
	float A_ao=1., B_ao=1.;
	if(A_ao_enabled) 
		AO = A_ao = dot(triplanar_texture(A_ao_map,A_uv_power_normal,A_uv_triplanar_pos),A_ao_texture_channel);
	if(B_ao_enabled)
		AO = B_ao = dot(triplanar_texture(B_ao_map,B_uv_power_normal,B_uv_triplanar_pos),B_ao_texture_channel);
	if(A_ao_enabled || B_ao_enabled) {
		AO = mix(B_ao, A_ao, clamp(AB_mix1 + 10.*normal.y + AB_mix2*A_albedo.b , 0., 1.));
		AO_LIGHT_AFFECT = mix(B_ao_strength, A_ao_strength, clamp(AB_mix1 + 10.*normal.y + AB_mix2*A_albedo.b , 0., 1.));
	}

	
	// Calculate Normals
	
	vec3 A_normal=vec3(0.5,0.5, 0.5);
	vec3 B_normal=vec3(0.5,0.5,0.5);	
	if(A_normal_enabled)
		A_normal = triplanar_texture(A_normal_map,A_uv_power_normal,A_uv_triplanar_pos).rgb;
	if(B_normal_enabled)
		B_normal = triplanar_texture(B_normal_map,B_uv_power_normal,B_uv_triplanar_pos).rgb;
	if(A_normal_enabled || B_normal_enabled) {
		NORMALMAP = mix(B_normal, A_normal, clamp(AB_mix1 + 10.*normal.y + AB_mix2*A_albedo.b , 0., 1.));
		NORMALMAP_DEPTH = mix(B_normal_strength, A_normal_strength, clamp(AB_mix1 + 10.*normal.y + AB_mix2*A_albedo.b , 0., 1.));
	}
	*/
}





/*

// http://www.iquilezles.org/www/articles/texturerepetition/texturerepetition.htm

vec4 hash4 ( vec2 p ) { return fract(sin(vec4( 1.0+dot(p,vec2(37.0,17.0)), 2.0+dot(p,vec2(11.0,47.0)), 3.0+dot(p,vec2(41.0,29.0)), 4.0+dot(p,vec2(23.0,31.0))))*103.0); }

vec4 textureNoTile( sampler2D samp, in vec2 uv ) {
    vec2 iuv = vec2( floor( uv ) );
    vec2 fuv = fract( uv );

    // generate per-tile transform
    vec4 ofa = hash4( iuv + vec2(0.,0.) );
    vec4 ofb = hash4( iuv + vec2(1.,0.) );
    vec4 ofc = hash4( iuv + vec2(0.,1.) );
    vec4 ofd = hash4( iuv + vec2(1.,1.) );
    
    vec2 ddx = dFdx( uv );
    vec2 ddy = dFdy( uv );

    // transform per-tile uvs
    ofa.zw = sign( ofa.zw-0.5 );
    ofb.zw = sign( ofb.zw-0.5 );
    ofc.zw = sign( ofc.zw-0.5 );
    ofd.zw = sign( ofd.zw-0.5 );
    
    // uv's, and derivatives (for correct mipmapping)
    vec2 uva = uv*ofa.zw + ofa.xy, ddxa = ddx*ofa.zw, ddya = ddy*ofa.zw;
    vec2 uvb = uv*ofb.zw + ofb.xy, ddxb = ddx*ofb.zw, ddyb = ddy*ofb.zw;
    vec2 uvc = uv*ofc.zw + ofc.xy, ddxc = ddx*ofc.zw, ddyc = ddy*ofc.zw;
    vec2 uvd = uv*ofd.zw + ofd.xy, ddxd = ddx*ofd.zw, ddyd = ddy*ofd.zw;
        
    // fetch and blend
    vec2 b = smoothstep( 0.25,0.75, fuv );
    
    return mix( mix( textureGrad( samp, uva, ddxa, ddya ), 
                     textureGrad( samp, uvb, ddxb, ddyb ), b.x ), 
                mix( textureGrad( samp, uvc, ddxc, ddyc ),
                     textureGrad( samp, uvd, ddxd, ddyd ), b.x), b.y );
}

float sum( vec3 v ) { return v.x+v.y+v.z; }

vec3 untiled_texture(sampler2D samp, in vec2 uv) {
	 // sample variation pattern    
    float k = texture( noise_texture, 0.005*uv ).x; // cheap (cache friendly) lookup    
    
    // compute index    
    float index = k*8.0;
    float i = floor( index );
    float f = fract( index );

    // offsets for the different virtual patterns    
    vec2 offa = sin(vec2(3.0,7.0)*(i+0.0)); // can replace with any other hash    
    vec2 offb = sin(vec2(3.0,7.0)*(i+1.0)); // can replace with any other hash    

    // compute derivatives for mip-mapping    
    vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
    
    // sample the two closest virtual patterns    
    vec3 cola = textureGrad( samp, uv + offa, dx, dy ).xyz;
    vec3 colb = textureGrad( samp, uv + offb, dx, dy ).xyz;

    // interpolate between the two virtual patterns    
    return mix( cola, colb, smoothstep(0.2,0.8,f-0.1*sum(cola-colb)) );
}
*/