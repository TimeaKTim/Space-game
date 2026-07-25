extends Node2D


@export var star_count := 160
@export var padding := 60.0
@export var drift_speed := 4.0

var _stars := []
var _t := 0.0

func _ready() -> void:
	randomize()
	var vp := get_viewport_rect().size
	for i in star_count:
		_stars.append({
			"pos": Vector2(
				randf_range(-padding, vp.x + padding),
				randf_range(-padding, vp.y + padding)
			),
			"radius": randf_range(0.5, 1.8),
			"base_alpha": randf_range(0.2, 0.95),
			"speed": randf_range(0.4, 1.6),
			"phase": randf_range(0.0, TAU),
			"tint": randf() > 0.85
		})
	set_process(true)

func _process(delta: float) -> void:
	_t += delta
	var vp := get_viewport_rect().size
	for s in _stars:
		s.pos.y += drift_speed * delta
		if s.pos.y > vp.y + padding:
			s.pos.y = -padding
			s.pos.x = randf_range(-padding, vp.x + padding)
	queue_redraw()

func _draw() -> void:
	for s in _stars:
		var a: float = s.base_alpha * (0.55 + 0.45 * sin(_t * s.speed + s.phase))
		var col := Color(0.75, 0.85, 1.0, a) if s.tint else Color(1, 1, 1, a)
		draw_circle(s.pos, s.radius, col)
