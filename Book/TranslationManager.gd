extends Node

# Dictionary tracking our A-Z progress
var unlocked_letters: Dictionary = {}

# UPDATE THIS PATH to wherever you saved your new font!
var alien_font_path: String = "res://Book/SpaceFont-Regular.ttf"

func _ready() -> void:
	# Initialize the alphabet. Every letter starts as locked (false)
	var alphabet = "abcdefghijklmnopqrstuvwxyz"
	for letter in alphabet:
		unlocked_letters[letter] = false
# NEW: Function to lock all letters (reset the alphabet)
func reset_alphabet() -> void:
	for letter in unlocked_letters.keys():
		unlocked_letters[letter] = false
	print("Alphabet reset: All letters are locked again!")
# Call this function whenever the player finds a clue
func unlock_letter(letter: String) -> void:
	var lower_letter = letter.to_lower()
	if unlocked_letters.has(lower_letter):
		unlocked_letters[lower_letter] = true
		print("Unlocked alien letter: ", lower_letter)

# NEW: Function to instantly unlock everything
func unlock_all_letters() -> void:
	for letter in unlocked_letters.keys():
		unlocked_letters[letter] = true
	print("Cheat activated: All alien letters unlocked!")

# NEW: Connect your Button's "pressed" signal to this function
func _on_button_pressed() -> void:
	unlock_all_letters()
	
	# Optional: If your RichTextLabel doesn't update automatically, 
	# you will need to refresh its text here or emit a signal so the UI knows to update.
	# Example: SignalBus.emit_signal("translation_updated")

# This converts normal English into a mix of English and Alien BBCode
func get_translated_text(english_text: String) -> String:
	var final_bbcode: String = ""
	
	for i in english_text.length():
		var char = english_text[i]
		var lower_char = char.to_lower()
		
		if unlocked_letters.has(lower_char):
			if unlocked_letters[lower_char] == true:
				# The letter is unlocked! Show it in English.
				final_bbcode += char
			else:
				# The letter is locked! Wrap it in the alien font BBCode.
				final_bbcode += "[font=\"" + alien_font_path + "\"]" + char + "[/font]"
		else:
			# It's a space, number, or punctuation mark. Add it normally.
			final_bbcode += char 
			
	return final_bbcode

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		unlock_all_letters()
