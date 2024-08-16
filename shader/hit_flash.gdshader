shader_type canvas_item;

uniform float lerp_percent : hint_range(0.0, 1.0, 0.1); 
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, flash_color, lerp_percent);
}
