extends Control
class_name FreqSlider

signal value_changed(value: float)

@export var min_value := 0.0
@export var max_value := 100.0
@export var start_value := 0.0
@export var marker_color := Color(0.35, 1.0, 0.55, 0.95)

@onready var track: ColorRect = $Track
@onready var handle: ColorRect = $Handle

var value := 0.0
var dragging := false

var has_marker := false
var marker_value := 0.0


func _ready() -> void:
	value = start_value
	track.gui_input.connect(_on_track_gui_input)
	handle.gui_input.connect(_on_handle_gui_input)
	set_process_input(true)
	_position_handle()


func _on_track_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true
		_update_value_from_global_x(event.global_position.x)


func _on_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true


func _input(event: InputEvent) -> void:
	if not dragging:
		return
	if event is InputEventMouseMotion:
		_update_value_from_global_x(event.global_position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false


func _update_value_from_global_x(global_x: float) -> void:
	var local_x: float = global_x - track.global_position.x
	var t: float = clamp(local_x / track.size.x, 0.0, 1.0)
	value = lerp(min_value, max_value, t)
	_position_handle()
	value_changed.emit(value)


func _position_handle() -> void:
	var t: float = inverse_lerp(min_value, max_value, value)
	handle.position.x = track.position.x + t * track.size.x - handle.size.x / 2.0


#func set_marker(target: float) -> void:
	#has_marker = true
	#marker_value = target
	#queue_redraw()


func clear_marker() -> void:
	has_marker = false
	queue_redraw()


func _draw() -> void:
	if not has_marker:
		return
	var t: float = inverse_lerp(min_value, max_value, marker_value)
	var x: float = track.position.x + t * track.size.x

	var apex := Vector2(x, 6.0)
	var tip_left := Vector2(x - 8.0, -12.0)
	var tip_right := Vector2(x + 8.0, -12.0)
	draw_colored_polygon(PackedVector2Array([tip_left, tip_right, apex]), marker_color)

	draw_line(Vector2(x, 6.0), Vector2(x, size.y), marker_color, 2.0)
