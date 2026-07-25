shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.55;
uniform float radius : hint_range(0.1, 1.5) = 0.85;
uniform float softness : hint_range(0.05, 1.0) = 0.55;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// Slightly flatten vertically so the vignette feels widescreen.
	float dist = length(uv * vec2(1.0, 0.8));
	float vig = smoothstep(radius, radius - softness, dist);
	COLOR = vec4(0.0, 0.0, 0.0, (1.0 - vig) * strength);
}
