extends Node2D
class_name Potion

@onready var sutyok: Sprite2D = $Sutyok
@onready var body: Sprite2D = $Body
@onready var cap: Sprite2D = $Cap
@onready var button: Button = $Button
@onready var area_2d: Area2D = $Area2D
@onready var belt: Sprite2D = $Belt

# NEW: Reference to the label on your Potion scene
@onready var value_label: RichTextLabel = $ValueLabel 

enum PotionState { FULL, EMPTY }
var current_state: PotionState = PotionState.FULL

@export var potion_value: int = 10 

var is_held: bool = false
var active_container: Area2D = null
var initial_position: Vector2 

func _ready() -> void:
	randomize() 
	
	var possible_primes: Array[int] = [2, 3, 5, 7]
	potion_value = possible_primes.pick_random()
	
	# NEW: Dictionary to convert the integer to an English word
	var number_to_word: Dictionary = {
		2: "Two",
		3: "Three",
		5: "Five",
		7: "Seven"
	}
	
	# Assign the text to the label and TRANSLATE it. 
	if value_label != null:
		# Force BBCode on
		value_label.bbcode_enabled = true
		
		# Get the raw English word
		var english_word = number_to_word[potion_value]
		
		# Pass it directly into the TranslationManager
		value_label.text = TranslationManager.get_translated_text(english_word)
	
	# Give the liquid a beautifully random hue!
	sutyok.self_modulate = Color.from_hsv(randf(), 1.0, 1.0, 1.0)
	
	initial_position = position 
	
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()

func _on_button_down() -> void:
	if current_state == PotionState.FULL:
		is_held = true
		z_index = 10 
		cap.visible = false
		belt.visible = false

func _on_button_up() -> void:
	is_held = false
	z_index = 0 
	
	if active_container != null and current_state == PotionState.FULL:
		pour_into_container()
	else:
		return_to_start()

func _on_area_entered(area: Area2D) -> void:
	if is_held and area.is_in_group("container"):
		active_container = area
		tilt_potion(-45.0) 

func _on_area_exited(area: Area2D) -> void:
	if area == active_container:
		active_container = null
		tilt_potion(0.0) 

func tilt_potion(target_degrees: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", deg_to_rad(target_degrees), 0.2)

func pour_into_container() -> void:
	if active_container.has_method("add_potion_code"):
		active_container.add_potion_code(potion_value, sutyok.self_modulate)
		position = initial_position
		set_empty()
	else:
		print("DEBUG: Container found, but add_potion_code method is missing!")

func set_empty() -> void:
	current_state = PotionState.EMPTY
	self.rotation = 0.0
	sutyok.visible = false
	cap.visible = true
	belt.visible = true
	
	# NEW: Hide the text when the potion is empty!
	if value_label != null:
		value_label.visible = false
		
	button.disabled = true

func return_to_start() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", initial_position, 0.2)
	cap.visible = true
	belt.visible = true
