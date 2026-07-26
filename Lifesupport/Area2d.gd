extends Area2D

signal combo_success
signal combo_failure

@onready var base: Sprite2D = $base
@onready var layer_1: Sprite2D = $Layer1
@onready var layer_2: Sprite2D = $Layer2
@onready var layer_3: Sprite2D = $Layer3
@onready var value_label: RichTextLabel = $ValueLabel

# THE FIX: Start at 1, otherwise multiplication stays at 0!
var total_combo_code: int = 1 
var target_success_code: int = 0
var potions_poured: int = 0
var current_liquid_color: Color = Color.WHITE

# The most common 3-prime combinations
var possible_targets: Array[int] = [30, 42, 70, 105]

func _ready() -> void:
	layer_1.visible = false
	layer_2.visible = false
	layer_3.visible = false
	
	# Randomize the target code
	target_success_code = possible_targets.pick_random()
	print("DEBUG: The secret target code is: ", target_success_code)
	
	# Dictionary to convert the target integer to an English word
	var target_to_word: Dictionary = {
		30: "Thirty",
		42: "Forty-Two",
		70: "Seventy",
		105: "One Hundred Five"
	}
	
	# THE FIX: Translate the text right here and enable BBCode!
	if value_label != null:
		# 1. Force BBCode on so the [font] tags actually work
		value_label.bbcode_enabled = true 
		
		# 2. Get the raw English word
		var english_word = target_to_word[target_success_code]
		
		# 3. Pass it directly into your TranslationManager!
		value_label.text = TranslationManager.get_translated_text(english_word)

func add_potion_code(value: int, potion_color: Color) -> void:
	total_combo_code *= value
	potions_poured += 1
	
	if potions_poured == 1:
		current_liquid_color = potion_color
	else:
		current_liquid_color = current_liquid_color.lerp(potion_color, 0.5)
	
	update_visual_layers()
	check_combo_result()

func update_visual_layers() -> void:
	if potions_poured >= 1:
		layer_1.visible = true
		layer_1.self_modulate = current_liquid_color
	if potions_poured >= 2:
		layer_2.visible = true
		layer_2.self_modulate = current_liquid_color
	if potions_poured >= 3:
		layer_3.visible = true
		layer_3.self_modulate = current_liquid_color

func check_combo_result() -> void:
	if total_combo_code == target_success_code:
		print("Success! You made the perfect recipe.")
		combo_success.emit()
		
	elif total_combo_code > target_success_code:
		print("Failure! The potion exceeded the target value.")
		combo_failure.emit()
		
	# THE FIX: If 3 potions are poured and it wasn't a success, explode!
	elif potions_poured >= 3:
		print("Failure! Reached level 3 but the mix was wrong.")
		combo_failure.emit()
