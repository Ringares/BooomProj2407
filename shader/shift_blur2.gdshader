shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 50.0) = 10.0;  // The height of the bobbing
uniform float speed : hint_range(0.0, 10.0) = 1.0;       // The speed of the bobbing
uniform vec2 direction = vec2(1.,1.);       // The speed of the bobbing

uniform int strength: hint_range(1, 512) = 2;

vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {
    
    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(strength);	

    vec2 pixel = fragCoord/pixelSize;
    int x_min = max(int(pixel.x-strengthFloat), 0);
    int x_max = min(int(pixel.x+strengthFloat), int(1./pixelSize.x));
    int y_min = max(int(pixel.y-strengthFloat), 0);
    int y_max = min(int(pixel.y+strengthFloat), int(1./pixelSize.y));

    int count =0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
        for(int y = y_min; y <= y_max; y++) {           
            color += texture(tex, vec2(float(x), float(y)) * pixelSize);
            count++;
        }
    }
    
    // Divide the color by the number of colors you summed up
    color /= float(count);
    
    return color;
}

void fragment() {	
	
	float offset = amplitude * sin(TIME * speed);
	vec2 offset_vec = normalize(direction);
	offset_vec = vec2(offset_vec.r*offset, offset_vec.g*offset);
	vec2 newUV = UV + offset_vec / 500.0;
    COLOR = texture(TEXTURE, UV + offset_vec / 500.0);
	
    //COLOR = blur_size(TEXTURE,newUV,TEXTURE_PIXEL_SIZE);
}