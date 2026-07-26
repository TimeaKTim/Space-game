extends Node2D

@onready var new_project: Sprite2D = $NewProject
@onready var potion: Potion = $Potion
@onready var potion_2: Potion = $Potion2
@onready var potion_3: Potion = $Potion3
@onready var potion_4: Potion = $Potion4
@onready var potion_5: Potion = $Potion5
@onready var potion_6: Potion = $Potion6
@onready var container: Area2D = $Container
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var explosion: AudioStreamPlayer2D = $Explosion

const NEXT_SCENE_PATH := "res://reward/symbol_reveal.tscn"
const WIN_TRANSITION_DELAY := 1.4

func _ready() -> void:
	animated_sprite_2d.visible = false 
	
	container.combo_success.connect(_on_combo_success)
	container.combo_failure.connect(_on_combo_failure)
	animated_sprite_2d.animation_finished.connect(_on_explosion_finished)
	
	# THE NEW LOGIC: Rig the game so it's always winnable!
	setup_guaranteed_solution()

func setup_guaranteed_solution() -> void:
	# Get the 3 exact numbers needed to win from the container
	var required_primes = container.get_required_primes()
	var all_primes: Array[int] = [2, 3, 5, 7]
	
	var potion_values: Array[int] = []
	potion_values.append_array(required_primes) # Add the 3 required numbers
	
	# Add 3 extra random numbers to fill the remaining potions
	for i in range(3):
		potion_values.append(all_primes.pick_random())
		
	# Shuffle the array so the winning potions aren't always the first 3!
	potion_values.shuffle()
	
	# Assign the generated values to each potion in the scene
	potion.setup_potion(potion_values[0])
	potion_2.setup_potion(potion_values[1])
	potion_3.setup_potion(potion_values[2])
	potion_4.setup_potion(potion_values[3])
	potion_5.setup_potion(potion_values[4])
	potion_6.setup_potion(potion_values[5])

func _on_combo_success() -> void:
	await get_tree().create_timer(WIN_TRANSITION_DELAY).timeout
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)

func _on_combo_failure() -> void:
	animated_sprite_2d.visible = true
	animated_sprite_2d.play() 
	explosion.play()
func _on_explosion_finished() -> void:
	get_tree().change_scene_to_file("res://Control_room/control_room.tscn")
