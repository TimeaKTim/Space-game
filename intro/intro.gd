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
var in_cutscene := false
var skipping := false

var titles := [
	"SALVAGE CONTRACT 2638",
	"MISSION BRIEFING",
	"BOARDING LOG",
]

var pages := [
	"""For decades, abandoned alien vessels have \ndrifted through explored space.

No one knows who built them.
No one knows why they were abandoned.

Entire industries now exist to recover their technology.

You are not a soldier.
You are a salvager.

Your assignment is simple:
• Board the vessel.
• Recover what you can.
• Leave.

Failure is acceptable.
Loss of recovered technology is not.""",

	"""A drifting alien vessel has been detected.

Long-range scans show no signs of life.
Most systems appear inactive.

Mission Objectives:
• Reach the bridge.
• Recover alien technology.
• Leave immediately.

Threat Assessment: UNKNOWN""",

	"""The ship is silent.
Every corridor is empty.

No bodies.
No explanation.

Eventually...

You reach the bridge.
One chair waits in the center.""",
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
	if event.is_action_pressed("ui_cancel") and not skipping:
		skip_intro()
		return

	if in_cutscene or fading or skipping:
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			story.visible_characters = -1
			is_typing = false
			return

		current_page += 1

		if current_page >= pages.size():
			play_final_sequence()
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


func play_final_sequence() -> void:
	story.visible_characters = -1
	in_cutscene = true
	is_typing = false

	var ui_fade := create_tween()
	ui_fade.tween_property(continue_label, "modulate:a", 0.0, 0.3)
	ui_fade.parallel().tween_property(page_dots, "modulate:a", 0.0, 0.3)

	story.text = ""
	title.text = "THE BRIDGE"

	var sequence := [
		["You sit down.", 1.0],
		["A monitor flickers.\n", 0.8],
		["Another.", 0.6],
		["Another.\n", 0.6],
		["[shake rate=18.0 level=6]CLUNK.[/shake]\n", 1.2],
		["The chair locks.", 0.7],
		["The bridge doors seal shut.", 1.0],
		["[wave amp=24 freq=3]Alien symbols spread across every display.[/wave]\n", 1.4],
		["[color=#8affc8]Connection Established.[/color]", 2.2],
	]

	for step in sequence:
		if skipping:
			break
		if step[0].begins_with("[shake"):
			_screen_shake()
		story.text += step[0] + "\n"
		await get_tree().create_timer(step[1]).timeout

	if not skipping:
		await get_tree().create_timer(3.0).timeout

	start_game()


func _screen_shake(strength: float = 6.0, duration: float = 0.3) -> void:
	var original_pos := position
	var shake_tween := create_tween()
	var steps := 6
	for i in steps:
		var offset := Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		shake_tween.tween_property(self, "position", original_pos + offset, duration / steps)
	shake_tween.tween_property(self, "position", original_pos, duration / steps)


func skip_intro() -> void:
	skipping = true
	is_typing = false
	in_cutscene = false
	fading = false
	start_game()


func start_game() -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.7)
	await tween.finished

	# get_tree().change_scene_to_file("res://main.tscn")
