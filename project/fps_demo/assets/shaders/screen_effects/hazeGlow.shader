shader_type canvas_item;
render_mode blend_add;

uniform float waves = 10.0;
uniform float speed = 40.0;
uniform float amplitude = 0.004;

const float M_PI = 3.1415926535897932384626433832795;

float map(float value, float min1, float max1, float min2, float max2)
{
    float perc = (value - min1) / (max1 - min1);
    return perc * (max2 - min2) + min2;
}

float colourDistance(vec4 compare, vec4 to)
{
    return sqrt((to.r - compare.r) * (to.r - compare.r) +
        	(to.g - compare.g) * (to.g - compare.g) +
        	(to.b - compare.b) * (to.b - compare.b));
}

float standardDeviation(vec3 colour)
{
    float mean = (colour.r + colour.g + colour.b) / 3.0;
    float sum = (colour.r - mean) * (colour.r - mean) +
        		(colour.g - mean) * (colour.g - mean) +
        		(colour.b - mean) * (colour.b - mean);
    
    float mean_sum = sum / 3.0;
    
    return sqrt(mean_sum);
}

float grayPercentage(vec3 colour)
{
    return 1.0-standardDeviation(colour.rgb);  
}

float heatDistortionIntensity(sampler2D tex, vec2 uvCoord)
{
    vec4 textureSample = texture(tex, uvCoord);
	
	// Uncomment for a colour based haze (black = more haze, not perfect)
    float result = float(1.0 - colourDistance(textureSample, vec4(1.0))) / 2.0;
    
    // Uncomment for a standard-deviation based colour analysis, based on how "gray" is a colour
    // Needs a very high resolution pic
    //float result = grayPercentage(textureSample.rgb);
    
    // Best result, a cubic function that restricts the haze to the "ground"
    //float result = (1.0-uvCoord.y) * (1.0-uvCoord.y) * (1.0-uvCoord.y);
    
    return map(result, 0.0, 1.0, 0.0, 0.5);
}

void fragment()
{
    float frequency = SCREEN_UV.y * 2.0 * M_PI * waves;
    float amp = amplitude * heatDistortionIntensity(SCREEN_TEXTURE, SCREEN_UV);
    float phase = M_PI/4.0 + TIME * speed;
    float sine_range = sin(-phase + frequency) * amp;
	float glow_affect = clamp(1.0 - distance(UV, vec2(0.5)) * 2.0, 0.0, 1.0);   
 
    vec2 distort = vec2(sine_range, sine_range * 5.0);
	
    // Output to screen
    COLOR.rgb = texture(SCREEN_TEXTURE, SCREEN_UV + distort).rgb;
	COLOR.a = glow_affect * 0.75;
}