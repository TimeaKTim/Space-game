extends Node2D

@onready var navigation: TextureButton = $Navigation
@onready var health_support: TextureButton = $HealthSupport
@onready var cables: TextureButton = $Cables
@onready var reactor: TextureButton = $Reactor
@onready var communication: TextureButton = $Communication

func _ready() -> void:
	# 1. Hide all buttons when the scene starts
	navigation.visible = false
	health_support.visible = false
	cables.visible = false
	reactor.visible = false
	communication.visible = false
	
	# 2. Wait for exactly 5 seconds before doing anything else
	await get_tree().create_timer(5.0).timeout
	
	# 3. Build a list of the baseline buttons
	var available_buttons = [navigation, health_support, cables, communication]
	
	# 4. Count unlocked letters from your Autoload
	var unlocked_count = 0
	for is_unlocked in TranslationManager.unlocked_letters.values():
		if is_unlocked == true:
			unlocked_count += 1
			
	# 5. Add the reactor if 15 or more characters are unlocked
	if unlocked_count >= 15:
		available_buttons.append(reactor)
		
	# 6. Pick exactly ONE random button and show it. It will stay until clicked.
	var chosen_button = available_buttons.pick_random()
	chosen_button.visible = true

func _on_book_pressed() -> void:
	get_tree().change_scene_to_file("res://Book/Book.tscn")
