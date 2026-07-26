extends Control

@export var core_radius := 34.0

var glow_color := Color(0.3, 1.0, 0.5, 1.0)


func set_state(color: Color) -> void:
	if glow_color == color:
		return
	glow_color = color
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size / 2.0

	for i in range(4, 0, -1):
		var r: float = core_radius + float(i) * 9.0
		var a: float = 0.05 * float(5 - i)
		draw_circle(center, r, Color(glow_color.r, glow_color.g, glow_color.b, a))

	draw_circle(center, core_radius, glow_color)
