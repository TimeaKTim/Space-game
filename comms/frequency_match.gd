extends Control

@onready var slider_a: FreqSlider = $ChannelA/SliderA
@onready var slider_b: FreqSlider = $ChannelB/SliderB
@onready var wave_a: WaveDisplay = $ChannelA/WaveDisplay
@onready var wave_b: WaveDisplay = $ChannelB/WaveDisplay
@onready var status_label: Label = $StatusLabel
@onready var static_player: AudioStreamPlayer = $StaticPlayer
@onready var signal_player: AudioStreamPlayer = $SignalPlayer
@onready var dot_not_okay: StatusDot = $StatusDotNotOkay
@onready var dot_okay: StatusDot = $StatusDotOkay

const COLOR_LOCKED_TEXT := Color(0.3, 1.0, 0.5)
const COLOR_SEARCHING_TEXT := Color(0.85, 0.85, 0.85)

const COLOR_DOT_OFF := Color(0.28, 0.27, 0.27, 1.0)      
const COLOR_DOT_RED := Color(0.95, 0.2, 0.18, 1.0)
const COLOR_DOT_GREEN_DIM := Color(0.15, 0.45, 0.2, 1.0)
const COLOR_DOT_GREEN_BRIGHT := Color(0.35, 1.0, 0.45, 1.0)
const FLASH_SPEED := 6.0 

const MIN_VALUE := 0.0
const MAX_VALUE := 100.0
const TOLERANCE := 4.0

const COUPLING := 0.35

const MAX_AUDIBLE_DISTANCE := 30.0
const MIN_LINEAR_VOLUME := 0.03

var target_a := 50.0
var target_b := 50.0
var locked := false
var flash_time := 0.0
var finished_game := false

signal signal_locked


func _ready() -> void:
	slider_a.value_changed.connect(_on_any_value_changed)
	slider_b.value_changed.connect(_on_any_value_changed)

	target_a = randf_range(MIN_VALUE + 10.0, MAX_VALUE - 10.0)
	target_b = randf_range(MIN_VALUE + 10.0, MAX_VALUE - 10.0)
	wave_a.set_target(target_a)
	wave_b.set_target(target_b)

	_setup_audio()
	_refresh()


func _setup_audio() -> void:
	static_player.stream = load("res://audio/static.mp3")
	signal_player.stream = load("res://audio/signal.mp3")

	static_player.finished.connect(func(): static_player.play())
	signal_player.finished.connect(func(): signal_player.play())

	static_player.play()
	signal_player.play()


func _process(delta: float) -> void:
	if not locked:
		return
	flash_time += delta * FLASH_SPEED
	var t: float = (sin(flash_time) * 0.5) + 0.5
	dot_okay.set_dot_color(COLOR_DOT_GREEN_DIM.lerp(COLOR_DOT_GREEN_BRIGHT, t))


func _on_any_value_changed(_v: float) -> void:
	_refresh()


func _combined_a() -> float:
	return clamp(slider_a.value * (1.0 - COUPLING) + slider_b.value * COUPLING, MIN_VALUE, MAX_VALUE)


func _combined_b() -> float:
	return clamp(slider_b.value * (1.0 - COUPLING) + slider_a.value * COUPLING, MIN_VALUE, MAX_VALUE)


func _refresh() -> void:
	var value_a := _combined_a()
	var value_b := _combined_b()

	wave_a.set_current(value_a)
	wave_b.set_current(value_b)

	#var needed_a: float = clamp((target_a - slider_b.value * COUPLING) / (1.0 - COUPLING), MIN_VALUE, MAX_VALUE)
	#var needed_b: float = clamp((target_b - slider_a.value * COUPLING) / (1.0 - COUPLING), MIN_VALUE, MAX_VALUE)
	#slider_a.set_marker(needed_a)
	#slider_b.set_marker(needed_b)

	var a_matched: bool = abs(value_a - target_a) <= TOLERANCE
	var b_matched: bool = abs(value_b - target_b) <= TOLERANCE
	var both_matched := a_matched and b_matched

	if both_matched or finished_game and not locked:
		status_label.text = "SIGNAL LOCKED"
		status_label.modulate = COLOR_LOCKED_TEXT
		signal_locked.emit()
		if !both_matched:
			locked = true
		else:
			locked = both_matched
	elif not both_matched:
		status_label.text = "SIGNAL: SEARCHING..."
		status_label.modulate = COLOR_SEARCHING_TEXT
		locked = both_matched

	if locked:
		dot_not_okay.set_dot_color(COLOR_DOT_OFF)
	else:
		flash_time = 0.0
		dot_not_okay.set_dot_color(COLOR_DOT_RED)
		dot_okay.set_dot_color(COLOR_DOT_OFF)

	_update_audio(value_a, value_b)


func _update_audio(value_a: float, value_b: float) -> void:
	var dist_a: float = abs(value_a - target_a)
	var dist_b: float = abs(value_b - target_b)

	var prox_a: float = 1.0 - clamp(dist_a / MAX_AUDIBLE_DISTANCE, 0.0, 1.0)
	var prox_b: float = 1.0 - clamp(dist_b / MAX_AUDIBLE_DISTANCE, 0.0, 1.0)

	var proximity: float = min(prox_a, prox_b)

	var clarity: float = proximity * proximity

	var signal_linear: float = clamp(clarity, MIN_LINEAR_VOLUME, 1.0)
	var static_linear: float = clamp(1.0 - clarity, MIN_LINEAR_VOLUME, 1.0)
	
	if signal_linear > 0.3:
		finished_game = true

	signal_player.volume_db = linear_to_db(signal_linear)
	static_player.volume_db = linear_to_db(static_linear)
