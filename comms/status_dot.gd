extends Control
class_name StatusDot

## Draws a filled circle sized to the node's rect, used to overlay the
## grey "indicator light" dots baked into the background art.

@export var dot_color: Color = Color(0.28, 0.27, 0.27, 1.0)
@export var glow: bool = false           ## draw a soft outer glow ring
@export var glow_color: Color = Color(1, 1, 1, 0.15)


func set_dot_color(c: Color) -> void:
	dot_color = c
	queue_redraw()


func _draw() -> void:
	var r: float = min(size.x, size.y) / 2.0
	var center: Vector2 = size / 2.0
	if glow:
		draw_circle(center, r * 1.35, glow_color)
	draw_circle(center, r, dot_color)
