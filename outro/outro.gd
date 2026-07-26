extends Control

@onready var story: RichTextLabel = $Story
@onready var fade: ColorRect = $FadeRect
@onready var continue_label: Label = $ContinueLabel
@onready var skip_label: Label = $SkipLabel
@onready var title: Label = $Title
@onready var page_dots: HBoxContainer = $PageDots

var current_page := 0
var fading := false
var typing_speed := 0.02
var is_typing := false
var in_closing := false
var awaiting_restart := false
var skipping := false

## Path to whatever scene should play when the player chooses to
## continue/replay from the very last screen. Point this at your main
## menu, credits, or the mission scene - whatever comes after the outro.
@export var next_scene_path: String = "res://frequency_match/frequency_match.tscn"

var titles := [
	"SIGNAL DECODED",
	"EXTRACTION",
	"CONTRACT 2638",
]

var pages := [
	"""The frequencies align.

For a moment, static gives way to something else.

Not language. Not exactly.

But data.
Coordinates. Warnings. A structure only now beginning to make sense.

Whatever this thing wanted to say, it's said it.""",

	"""Your suit records everything it can hold.

Somewhere below, the vessel's power core begins to destabilize.

Whatever this ship was carrying, it wasn't meant to be found.

Time to leave.""",

	"""You make it back to your shuttle.

The alien vessel falls away behind you, swallowed by the dark.

Back at the station, someone is going to ask a lot of questions.

You already know you won't have all the answers.""",
]

var dot_nodes: Array[ColorRect] = []


func _ready() -> void:
	story.bbcode_enabled = true
	story.visible_characters = 0

	_build_page_dots()

	story.text = pages[0]
	title.text = titles[0]
	title.modulate.a = 0.0

	_update_dots()
	type_page()

	var title_tween := create_tween()
	title_tween.tween_property(title, "modulate:a", 1.0, 0.6)

	var pulse := create_tween()
	pulse.set_loops()
	pulse.tween_property(continue_label, "modulate:a", 0.2, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(continue_label, "modulate:a", 1.0, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not skipping and not awaiting_restart:
		skip_outro()
		return

	if awaiting_restart:
		if event.is_action_pressed("ui_accept"):
			_go_to_next_scene()
		return

	if in_closing or fading or skipping:
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			story.visible_characters = -1
			is_typing = false
			return

		current_page += 1

		if current_page >= pages.size():
			play_closing_sequence()
		else:
			fade_to_next_page()


func _build_page_dots() -> void:
	for child in page_dots.get_children():
		child.queue_free()
	dot_nodes.clear()

	for i in pages.size():
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(7, 7)
		dot.color = Color(1, 1, 1, 1)
		dot.modulate.a = 0.25
		page_dots.add_child(dot)
		dot_nodes.append(dot)


func _update_dots() -> void:
	for i in dot_nodes.size():
		var target_alpha := 1.0 if i == current_page else 0.25
		var t := create_tween()
		t.tween_property(dot_nodes[i], "modulate:a", target_alpha, 0.25)


func fade_to_next_page() -> void:
	fading = true
	var tween := create_tween()

	tween.tween_property(fade, "modulate:a", 1.0, 0.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_callback(func():
		story.text = pages[current_page]
		title.text = titles[current_page]
		_update_dots()
		type_page()
	)

	tween.tween_property(fade, "modulate:a", 0.0, 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		fading = false
	)


func type_page() -> void:
	is_typing = true
	story.visible_characters = 0

	var length := story.get_total_character_count()

	for i in length:
		if not is_typing:
			break
		story.visible_characters = i + 1
		await get_tree().create_timer(typing_speed).timeout

	story.visible_characters = -1
	is_typing = false


func play_closing_sequence() -> void:
	story.visible_characters = -1
	in_closing = true
	is_typing = false

	var ui_fade := create_tween()
	ui_fade.tween_property(continue_label, "modulate:a", 0.0, 0.3)
	ui_fade.parallel().tween_property(page_dots, "modulate:a", 0.0, 0.3)
	ui_fade.parallel().tween_property(skip_label, "modulate:a", 0.0, 0.3)

	story.text = ""
	title.text = "SALVAGE COMPLETE"

	var sequence := [
		["Transmission archived.", 1.0],
		["Contract status: [color=#8affc8]COMPLETE[/color]", 1.6],
		["", 0.8],
		["[wave amp=16 freq=2]Thank you for playing.[/wave]", 2.6],
	]

	for step in sequence:
		if skipping:
			break
		story.text += step[0] + "\n"
		await get_tree().create_timer(step[1]).timeout

	_show_restart_prompt()


func _show_restart_prompt() -> void:
	awaiting_restart = true
	continue_label.text = "Press SPACE to play again"
	continue_label.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(continue_label, "modulate:a", 1.0, 0.8)


func skip_outro() -> void:
	skipping = true
	is_typing = false
	in_closing = false
	fading = false
	story.visible_characters = -1
	story.text = "Contract status: COMPLETE"
	title.text = "SALVAGE COMPLETE"
	_show_restart_prompt()


func _go_to_next_scene() -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.7)
	await tween.finished

	get_tree().change_scene_to_file(next_scene_path)
