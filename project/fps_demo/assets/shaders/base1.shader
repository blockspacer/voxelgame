shader_type spatial;

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


varying vec3 v_world_pos;
varying vec3 v_world_normal;




void vertex() {
	v_world_pos = VERTEX;
	v_world_normal = NORMAL;

}



void fragment() {
	
	if(v_world_normal.g>0.8)		ALBEDO = vec3(0,0.2*v_world_normal.g,0.03); 
	else if (v_world_normal.g>0.5)	ALBEDO = vec3(0.2*v_world_normal.g,0.1*v_world_normal.g,0); 
	else 							ALBEDO = vec3(0.01+0.2*v_world_normal.g,0.005 + 0.1*v_world_normal.g,0); 
		//v_world_pos; //vec3(1,0,0);
	
	
	//AO = v_world_normal.g;
	//NORMAL = get_normal(INV_CAMERA_MATRIX, WORLD_MATRIX, triblend);
	
	
}





