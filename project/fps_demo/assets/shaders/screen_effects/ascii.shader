// https://www.shadertoy.com/view/4ll3RB

shader_type canvas_item;

// referenced the method of bitmap of iq : https://www.shadertoy.com/view/4dfXWj

uniform float zoom = 0.01;

float P(ivec2 pos, float cha, int id,int a,int b,int c,int d,int e,int f,int g,int h) 
{
	if( id == int(pos.y) )
	{ 
		int pa = a+2*(b+2*(c+2*(d+2*(e+2*(f+2*(g+2*(h))))))); 
		cha = floor(mod(float(pa)/pow(2.,float(pos.x)-1.),2.)); 
	}
	return cha;
}

float gray(vec3 _i)
{
    return _i.x*0.299+_i.y*0.587+_i.z*0.114;
}

void fragment() 
{
	vec2 resolution = 1.0/SCREEN_PIXEL_SIZE;
    vec2 uv = SCREEN_UV;//vec2(floor(FRAGCOORD.x/8./zoom)*8.*zoom,floor(FRAGCOORD.y/12./zoom)*12.*zoom)/resolution;
	//uv = uv;
    ivec2 pos = ivec2(int(mod(FRAGCOORD.x/zoom,8.)),int(mod(FRAGCOORD.y/zoom,12.)));
    vec4 tex = texture(SCREEN_TEXTURE,uv);
    float cha = 0.;
    float g = gray(tex.xyz);
    if( g < .125 )
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 9,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 8,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 7,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 6,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 5,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 4,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 3,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 2,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 1,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else if( g < .25 ) // .
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 9,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 8,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 7,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 6,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 5,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 4,0,0,0,1,1,0,0,0);
        cha = P(pos, cha, 3,0,0,0,1,1,0,0,0);
        cha = P(pos, cha, 2,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 1,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else if( g < .375 ) // ,
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 9,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 8,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 7,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 6,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 5,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 4,0,0,0,1,1,0,0,0);
        cha = P(pos, cha, 3,0,0,0,1,1,0,0,0);
        cha = P(pos, cha, 2,0,0,0,0,1,0,0,0);
        cha = P(pos, cha, 1,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else if( g < .5 ) // -
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 9,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 8,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 7,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 6,1,1,1,1,1,1,1,0);
        cha = P(pos, cha, 5,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 4,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 3,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 2,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 1,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else if(g < .625 ) // +
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 9,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 8,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 7,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 6,1,1,1,1,1,1,1,0);
        cha = P(pos, cha, 5,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 4,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 3,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 2,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 1,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else if(g < .75 ) // *
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 9,1,0,0,1,0,0,1,0);
        cha = P(pos, cha, 8,0,1,0,1,0,1,0,0);
        cha = P(pos, cha, 7,0,0,1,1,1,0,0,0);
        cha = P(pos, cha, 6,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 5,0,0,1,1,1,0,0,0);
        cha = P(pos, cha, 4,0,1,0,1,0,1,0,0);
        cha = P(pos, cha, 3,1,0,0,1,0,0,1,0);
        cha = P(pos, cha, 2,0,0,0,1,0,0,0,0);
        cha = P(pos, cha, 1,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else if(g < .875 ) // #
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,1,0,0,1,0,0);
        cha = P(pos, cha, 9,0,0,1,0,0,1,0,0);
        cha = P(pos, cha, 8,1,1,1,1,1,1,1,0);
        cha = P(pos, cha, 7,0,0,1,0,0,1,0,0);
        cha = P(pos, cha, 6,0,0,1,0,0,1,0,0);
        cha = P(pos, cha, 5,0,1,0,0,1,0,0,0);
        cha = P(pos, cha, 4,0,1,0,0,1,0,0,0);
        cha = P(pos, cha, 3,1,1,1,1,1,1,1,0);
        cha = P(pos, cha, 2,0,1,0,0,1,0,0,0);
        cha = P(pos, cha, 1,0,1,0,0,1,0,0,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    else // @
    {
        cha = P(pos, cha, 11,0,0,0,0,0,0,0,0);
        cha = P(pos, cha, 10,0,0,1,1,1,1,0,0);
        cha = P(pos, cha, 9,0,1,0,0,0,0,1,0);
        cha = P(pos, cha, 8,1,0,0,0,1,1,1,0);
        cha = P(pos, cha, 7,1,0,0,1,0,0,1,0);
        cha = P(pos, cha, 6,1,0,0,1,0,0,1,0);
        cha = P(pos, cha, 5,1,0,0,1,0,0,1,0);
        cha = P(pos, cha, 4,1,0,0,1,0,0,1,0);
        cha = P(pos, cha, 3,1,0,0,1,1,1,1,0);
        cha = P(pos, cha, 2,0,1,0,0,0,0,0,0);
        cha = P(pos, cha, 1,0,0,1,1,1,1,1,0);
        cha = P(pos, cha, 0,0,0,0,0,0,0,0,0);
    }
    
    vec3 col = tex.xyz/max(tex.x,max(tex.y,tex.z));
    COLOR = vec4(cha*col,1.);
    //COLOR = vec4(col,1.);
    //COLOR = vec4(cha*tex.xyz,1.);
	//COLOR = tex;
}