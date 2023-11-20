shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	COLOR.a = abs(sin(COLOR.r * 3.0 * abs(sin(TIME)))); // glowing effect
	COLOR.a = pow(COLOR.a, 3); // remove gray
}
