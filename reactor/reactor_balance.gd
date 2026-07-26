extends Control

@onready var track: ColorRect = $Gauge/Track
@onready var safe_zone: ColorRect = $Gauge/SafeZone
@onready var needle: ColorRect = $Gauge/Needle
@onready var stability_bg: ColorRect = $StabilityBar/Background
@onready var stability_fill: ColorRect = $StabilityBar/Fill
@onready var coolant_button: ColorRect = $CoolantButton
@onready var fuel_button: ColorRect = $FuelButton
@onready var core_glow: Control = $CoreGlow

const MIN_VALUE := 0.0
const MAX_VALUE := 100.0
const SAFE_MIN := 44.0
const SAFE_MAX := 56.0

const STABILIZE_TIME := 6.5        
const STABILITY_DRAIN_MULT := 2.2  

const INPUT_ACCEL := 46.0          
const DAMPING := 0.85              

const DRIFT_MAX_ACCEL := 30.0     
const DRIFT_MIN_INTERVAL := 0.35
const DRIFT_MAX_INTERVAL := 0.9
const DRIFT_RESPONSIVENESS := 2.4  

const COLOR_SAFE := Color(0.3, 1.0, 0.5)
const COLOR_UNSAFE := Color(0.9, 0.7, 0.2)
const COLOR_TEXT_DEFAULT := Color(0.85, 0.85, 0.85)
const COLOR_WIN := Color(0.3, 1.0, 0.5)
const COLOR_FAIL := Color(0.9, 0.25, 0.25)

const COLOR_COOLANT_IDLE := Color(0.4, 0.85, 1.0, 0.12)
const COLOR_COOLANT_HELD := Color(0.4, 0.85, 1.0, 0.4)
const COLOR_FUEL_IDLE := Color(0.95, 0.6, 0.25, 0.12)
const COLOR_FUEL_HELD := Color(0.95, 0.6, 0.25, 0.4)

const NEXT_SCENE_PATH := "res://reward/symbol_reveal.tscn"
const WIN_TRANSITION_DELAY := 1.4

enum State { PLAYING, WON, LOST }

var value := 50.0
var velocity := 0.0
var drift_accel := 0.0
var drift_target := 0.0
var drift_timer := 0.0
var stability := 0.0
var holding_coolant := false
var holding_fuel := false
var state := State.PLAYING


func _ready() -> void:
	coolant_button.gui_input.connect(_on_coolant_input)
	fuel_button.gui_input.connect(_on_fuel_input)
	set_process_input(true)

	_position_safe_zone()
	_reset_run()


func _reset_run() -> void:
	value = 50.0
	velocity = 0.0
	drift_accel = 0.0
	drift_target = 0.0
	drift_timer = 0.0
	stability = 0.0
	holding_coolant = false
	holding_fuel = false
	state = State.PLAYING

	_update_needle()
	_update_stability_bar()


func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	var kb_coolant: bool = Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A)
	var kb_fuel: bool = Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D)

	var coolant_active: bool = holding_coolant or kb_coolant
	var fuel_active: bool = holding_fuel or kb_fuel

	_update_drift(delta)

	var accel := drift_accel
	if coolant_active:
		accel -= INPUT_ACCEL
	if fuel_active:
		accel += INPUT_ACCEL

	velocity += accel * delta
	velocity -= velocity * DAMPING * delta
	value += velocity * delta

	if value <= MIN_VALUE:
		value = MIN_VALUE
		_end_run(false, "REACTOR SCRAM")
	elif value >= MAX_VALUE:
		value = MAX_VALUE
		_end_run(false, "CORE MELTDOWN")

	var in_zone: bool = value >= SAFE_MIN and value <= SAFE_MAX
	if state == State.PLAYING:
		if in_zone:
			stability += delta
		else:
			stability -= delta * STABILITY_DRAIN_MULT
		stability = clamp(stability, 0.0, STABILIZE_TIME)

		if stability >= STABILIZE_TIME:
			_end_run(true, "REACTOR STABLE")

	_update_needle(in_zone)
	_update_stability_bar()
	coolant_button.color = COLOR_COOLANT_HELD if coolant_active else COLOR_COOLANT_IDLE
	fuel_button.color = COLOR_FUEL_HELD if fuel_active else COLOR_FUEL_IDLE


func _update_drift(delta: float) -> void:
	drift_timer -= delta
	if drift_timer <= 0.0:
		drift_target = randf_range(-DRIFT_MAX_ACCEL, DRIFT_MAX_ACCEL)
		drift_timer = randf_range(DRIFT_MIN_INTERVAL, DRIFT_MAX_INTERVAL)
	drift_accel = lerp(drift_accel, drift_target, delta * DRIFT_RESPONSIVENESS)


func _position_safe_zone() -> void:
	var w: float = track.size.x
	var t0: float = inverse_lerp(MIN_VALUE, MAX_VALUE, SAFE_MIN)
	var t1: float = inverse_lerp(MIN_VALUE, MAX_VALUE, SAFE_MAX)
	safe_zone.position.x = track.position.x + t0 * w
	safe_zone.size.x = (t1 - t0) * w


func _update_needle(in_zone: bool = false) -> void:
	var t: float = inverse_lerp(MIN_VALUE, MAX_VALUE, value)
	needle.position.x = track.position.x + t * track.size.x - needle.size.x / 2.0
	var color: Color = COLOR_SAFE if in_zone else COLOR_UNSAFE
	needle.color = color
	core_glow.set_state(color)


func _update_stability_bar() -> void:
	var t: float = stability / STABILIZE_TIME
	stability_fill.size.x = stability_bg.size.x * t


func _end_run(won: bool, message: String) -> void:
	state = State.WON if won else State.LOST
	var color: Color = COLOR_WIN if won else COLOR_FAIL
	needle.color = color
	core_glow.set_state(color)

	if won:
		await get_tree().create_timer(WIN_TRANSITION_DELAY).timeout
		get_tree().change_scene_to_file(NEXT_SCENE_PATH)


func _on_coolant_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		holding_coolant = event.pressed


func _on_fuel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		holding_fuel = event.pressed


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		holding_coolant = false
		holding_fuel = false

	if state != State.LOST:
		return
	if event.is_action_pressed("ui_accept"):
		_reset_run()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_reset_run()
