shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	COLOR.a = abs(sin(max(COLOR.r, COLOR.g) * 2.0 * abs(sin(TIME)))); // glowing effect
	COLOR.a = pow(COLOR.a, 3); // remove gray
}
