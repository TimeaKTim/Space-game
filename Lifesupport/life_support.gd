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

const NEXT_SCENE_PATH := "res://reward/symbol_reveal.tscn"
const WIN_TRANSITION_DELAY := 1.4

func _ready() -> void:
	# Hide the explosion at the start of the game
	animated_sprite_2d.visible = false 
	
	# Connect to the container's custom signals
	container.combo_success.connect(_on_combo_success)
	container.combo_failure.connect(_on_combo_failure)
	
	# Connect to the AnimatedSprite2D's built-in finish signal
	animated_sprite_2d.animation_finished.connect(_on_explosion_finished)

func _on_combo_success() -> void:
	# If successful, wait and change scene
	await get_tree().create_timer(WIN_TRANSITION_DELAY).timeout
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)

func _on_combo_failure() -> void:
	# If failure, show the explosion and play it
	animated_sprite_2d.visible = true
	animated_sprite_2d.play() 

func _on_explosion_finished() -> void:
	# Once the explosion finishes its last frame, move to control room
	get_tree().change_scene_to_file("res://Control_room/control_room.tscn")
