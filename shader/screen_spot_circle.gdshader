shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float modulate_recovery = 1.0;

varying vec2 center_uv;

void vertex(){
	center_uv = (SCREEN_MATRIX * CANVAS_MATRIX * MODEL_MATRIX * vec4(0.5,0.5,0,1)).xy;
	center_uv = (center_uv + 1.0) / 2.0;
}

void fragment() {
	
	vec2 uv_difference = SCREEN_UV - center_uv;
	vec2 new_uv = center_uv + uv_difference / 1.0;
	vec4 sampled_color = texture(screen_tex, new_uv);
	
	COLOR.rgb = sampled_color.rgb * modulate_recovery;
	//float brightness = sampled_color.r * 0.299 + sampled_color.g * 0.587 + sampled_color.b * 0.114;
	//COLOR.rgb = vec3(brightness);
	//
	//COLOR.rg = center_uv.xy;
	//COLOR.b=0.0;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
