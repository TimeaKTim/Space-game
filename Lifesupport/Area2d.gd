extends Area2D

# NEW: Define custom signals
signal combo_success
signal combo_failure

@onready var base: Sprite2D = $base
@onready var layer_1: Sprite2D = $Layer1
@onready var layer_2: Sprite2D = $Layer2
@onready var layer_3: Sprite2D = $Layer3

var total_combo_code: int = 0
var target_success_code: int = 25 # Example target
var potions_poured: int = 0
var current_liquid_color: Color = Color.WHITE

func _ready() -> void:
	layer_1.visible = false
	layer_2.visible = false
	layer_3.visible = false

func add_potion_code(value: int, potion_color: Color) -> void:
	total_combo_code += value
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
		# THE NEW LINE: Shout out that it was a success!
		combo_success.emit()
		
	elif total_combo_code > target_success_code:
		print("Failure! The cauldron exploded.")
		# THE NEW LINE: Shout out that it failed!
		combo_failure.emit()
