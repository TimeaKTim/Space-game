extends Node2D
class_name Potion

@onready var sutyok: Sprite2D = $Sutyok
@onready var body: Sprite2D = $Body
@onready var cap: Sprite2D = $Cap
@onready var button: Button = $Button
@onready var area_2d: Area2D = $Area2D
@onready var belt: Sprite2D = $Belt

enum PotionState { FULL, EMPTY }
var current_state: PotionState = PotionState.FULL

@export var potion_value: int = 10 

var is_held: bool = false
var active_container: Area2D = null
var initial_position: Vector2 

func _ready() -> void:
	randomize() 
	potion_value = randi_range(1, 15)
	
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
		belt.visible=false
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
		
		# THE NEW LINE: Pass the potion's value AND its color to the container!
		active_container.add_potion_code(potion_value, sutyok.self_modulate)
		
		position = initial_position
		set_empty()
	else:
		print("DEBUG: Container found, but add_potion_code method is missing!")

func set_empty() -> void:
	current_state = PotionState.EMPTY
	self.rotation = 0.0
	
	# Hide the liquid completely!
	sutyok.visible = false
	
	cap.visible = true
	belt.visible=true
	button.disabled = true

func return_to_start() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", initial_position, 0.2)
	cap.visible = true
	belt.visible=true
