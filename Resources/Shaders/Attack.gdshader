shader_type canvas_item;

uniform sampler2D n;

void fragment() {
	COLOR = texture(TEXTURE, UV); //read from texture
	
	vec4 noise = texture(n, UV - TIME / 1.0);
	
	COLOR.rgb = vec3(0.190, 0.025, 0.025);// - vec3(0.05);
	
	COLOR.a = abs(sin(TIME - noise.r)) + 0.55;
}
