shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 50.0) = 10.0;  // The height of the bobbing
uniform float speed : hint_range(0.0, 10.0) = 1.0;       // The speed of the bobbing
uniform vec2 direction = vec2(1.,1.);       // The speed of the bobbing

// Radius that the shader was designed for.
const float DEFAULT_RADIUS = 10.000000;

// Unit vector: (1, 0) or (0, 1)
uniform vec2 step;
// Desired blur radius.
uniform float radius = 10.000000;


void fragment() {
    float offset = amplitude * sin(TIME * speed);
	vec2 offset_vec = normalize(direction);
	offset_vec = vec2(offset_vec.r*offset, offset_vec.g*offset);
	vec2 newUV = UV + offset_vec / 500.0;
    COLOR = texture(TEXTURE, UV + offset_vec / 500.0);
	
	vec2 s = radius / DEFAULT_RADIUS * step / vec2(textureSize(TEXTURE, 0));
	COLOR.rgb =
		0.011194727 * texture(TEXTURE, newUV - 10.000000000 * s).rgb +
		0.039368696 * texture(TEXTURE, newUV - 8.415809477 * s).rgb +
		0.071308558 * texture(TEXTURE, newUV - 6.435363708 * s).rgb +
		0.110237219 * texture(TEXTURE, newUV - 4.455121108 * s).rgb +
		0.145451038 * texture(TEXTURE, newUV - 2.475020813 * s).rgb +
		0.163798995 * texture(TEXTURE, newUV - 0.495000167 * s).rgb +
		0.157439298 * texture(TEXTURE, newUV + 1.485004498 * s).rgb +
		0.129158204 * texture(TEXTURE, newUV + 3.465057055 * s).rgb +
		0.090434685 * texture(TEXTURE, newUV + 5.445220765 * s).rgb +
		0.054043977 * texture(TEXTURE, newUV + 7.425557483 * s).rgb +
		0.027564604 * texture(TEXTURE, newUV + 9.406126897 * s).rgb;
	COLOR.a = 1.0;
}
