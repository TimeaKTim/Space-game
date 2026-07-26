extends Control

const ALPHABET := "abcdefghijklmnopqrstuvwxyz"

@onready var fade: ColorRect = $FadeRect
@onready var symbol_labels: Array = [$SymbolsColumn/Symbol1, $SymbolsColumn/Symbol2, $SymbolsColumn/Symbol3]

var chosen_letters: Array[String] = []

signal symbols_ready(letters: Array)


func _ready() -> void:
	randomize()
	chosen_letters = _pick_random_letters(3)

	for i in symbol_labels.size():
		var letter: String = chosen_letters[i]
		symbol_labels[i].text = _display_text_for(letter)

	symbols_ready.emit(chosen_letters)

	fade.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _pick_random_letters(count: int) -> Array[String]:
	var pool: Array[String] = []
	for letter in ALPHABET:
		pool.append(letter)
	pool.shuffle()
	var picked: Array[String] = []
	for i in count:
		picked.append(pool[i])
	return picked

func _display_text_for(letter: String) -> String:
	var translator := get_node_or_null("/root/TranslationManager")
	var symbol_text: String = letter.to_upper() if translator == null else translator.get_translated_text(letter)
	return "%s [font_size=40][color=#8fa3b8]=[/color] %s[/font_size]" % [symbol_text, letter.to_upper()]

func unlock_and_refresh(letter: String) -> void:
	var translator := get_node_or_null("/root/TranslationManager")
	if translator:
		translator.unlock_letter(letter)
	for i in chosen_letters.size():
		symbol_labels[i].text = _display_text_for(chosen_letters[i])
