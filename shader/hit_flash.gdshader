shader_type canvas_item;

uniform float lerp_percent : hint_range(0.0, 1.0, 0.1); 

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.,1.,1.),lerp_percent);
}
