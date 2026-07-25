extends Control
class_name WaveDisplay

@export var min_value := 0.0
@export var max_value := 100.0
@export var cycles_min := 2.0
@export var cycles_max := 10.0
@export var amplitude := 34.0
@export var current_color := Color(0.4, 0.9, 1.0, 1.0)
@export var target_color := Color(1.0, 1.0, 1.0, 0.35)
@export var axis_color := Color(1, 1, 1, 0.08)

var target_value := 50.0
var current_value := 0.0


func _ready() -> void:
	clip_contents = true


func set_target(value: float) -> void:
	target_value = value
	queue_redraw()


func set_current(value: float) -> void:
	current_value = value
	queue_redraw()


func _value_to_cycles(value: float) -> float:
	var t: float = inverse_lerp(min_value, max_value, value)
	return lerp(cycles_min, cycles_max, t)


func _draw_wave(cycles: float, color: Color, line_width: float) -> void:
	var w: float = size.x
	var h: float = size.y
	var center_y: float = h / 2.0
	var steps := 200
	var points := PackedVector2Array()
	for i in steps + 1:
		var x: float = w * float(i) / float(steps)
		var y: float = center_y - amplitude * sin(TAU * cycles * (x / w))
		points.append(Vector2(x, y))
	draw_polyline(points, color, line_width, true)


func _draw() -> void:
	draw_line(Vector2(0, size.y / 2.0), Vector2(size.x, size.y / 2.0), axis_color, 1.0)
	_draw_wave(_value_to_cycles(target_value), target_color, 2.0)
	_draw_wave(_value_to_cycles(current_value), current_color, 3.0)
