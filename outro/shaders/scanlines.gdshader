shader_type canvas_item;

uniform float line_spacing : hint_range(1.0, 8.0) = 3.0;
uniform float opacity : hint_range(0.0, 0.3) = 0.07;

void fragment() {
	float line = mod(FRAGCOORD.y, line_spacing);
	float dark = step(line_spacing * 0.5, line);
	COLOR = vec4(0.0, 0.0, 0.0, dark * opacity);
}
