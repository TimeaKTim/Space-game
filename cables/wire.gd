class_name Wire
extends Node2D

@export var texture : Texture2D:
	set(value):
		texture = value
		queue_redraw()

@export var segment_size: Vector2:
	set(value):
		segment_size = value
		queue_redraw()

@export var from: Vector2:
	set(value):
		from = value
		queue_redraw()
		
@export var to: Vector2:
	set(value):
		to = value
		queue_redraw()

func init(pos: Vector2):
	from = pos
	to = pos

func clear() -> void:
	self.from = Vector2.ZERO
	self.to = Vector2.ZERO

func _draw() -> void:
	if texture == null or from == null or to == null:
		return
	
	# segment size with texture fallback
	var seg_size: Vector2
	if self.segment_size == null or self.segment_size == Vector2.ZERO:
		seg_size = texture.get_size()
	else:
		seg_size = self.segment_size
	
	# set transform
	draw_set_transform(from, from.angle_to_point(to))
	
	var segments: float = from.distance_to(to) / seg_size.x
	if segments == 0:
		return
	
	var whole_segments: int = int(segments)
	var remainder := segments - whole_segments
	for i in range(whole_segments + 1):
		var rect := Rect2(
			seg_size.x * i,
			-seg_size.y / 2,
			seg_size.x,
			seg_size.y
		)
		
		if i < whole_segments:
			# draw whole segments
			draw_texture_rect(texture, rect, false)
		else:
			# draw remainder segment
			var src := Rect2(Vector2.ZERO, seg_size)
			src.size.x *= remainder
			rect.size.x *= remainder
			draw_texture_rect_region(texture, rect, src)
