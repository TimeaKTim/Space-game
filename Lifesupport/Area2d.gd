extends Area2D

signal combo_success
signal combo_failure

@onready var base: Sprite2D = $base
@onready var layer_1: Sprite2D = $Layer1
@onready var layer_2: Sprite2D = $Layer2
@onready var layer_3: Sprite2D = $Layer3
@onready var value_label: RichTextLabel = $ValueLabel

var total_combo_code: int = 1 
var target_success_code: int = 0
var potions_poured: int = 0
var current_liquid_color: Color = Color.WHITE

var possible_targets: Array[int] = [30, 42, 70, 105]

func _ready() -> void:
	layer_1.visible = false
	layer_2.visible = false
	layer_3.visible = false
	
	target_success_code = possible_targets.pick_random()
	print("DEBUG: The secret target code is: ", target_success_code)
	
	var target_to_word: Dictionary = {
		30: "Thirty",
		42: "Forty-Two",
		70: "Seventy",
		105: "One Hundred Five"
	}
	
	if value_label != null:
		value_label.bbcode_enabled = true 
		var english_word = target_to_word[target_success_code]
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
	elif potions_poured >= 3:
		print("Failure! Reached level 3 but the mix was wrong.")
		combo_failure.emit()

# THE NEW LOGIC: This tells the Level Controller exactly what 3 primes make up the target
func get_required_primes() -> Array[int]:
	match target_success_code:
		30: return [2, 3, 5]
		42: return [2, 3, 7]
		70: return [2, 5, 7]
		105: return [3, 5, 7]
		
	return [2, 3, 5] # Fallback just in case
