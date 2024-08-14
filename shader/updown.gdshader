shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 50.0) = 10.0;  // The height of the bobbing
uniform float speed : hint_range(0.0, 10.0) = 1.0;       // The speed of the bobbing
uniform vec2 direction = vec2(1.,1.);       // The speed of the bobbing

void fragment() {
    float offset = amplitude * sin(TIME * speed);
	vec2 offset_vec = normalize(direction);
	offset_vec = vec2(offset_vec.r*offset, offset_vec.g*offset);
    COLOR = texture(TEXTURE, UV + offset_vec / 500.0);
}
