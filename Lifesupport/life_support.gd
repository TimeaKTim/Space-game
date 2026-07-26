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
	# 1. Hide the explosion at the start of the game
	animated_sprite_2d.visible = false 
	
	# 2. Connect to the container's custom signals
	container.combo_success.connect(_on_combo_success)
	container.combo_failure.connect(_on_combo_failure)
	
	# 3. Connect to the AnimatedSprite2D's built-in finish signal
	animated_sprite_2d.animation_finished.connect(_on_explosion_finished)


func _on_combo_success() -> void:
	# If successful, quit the game instantly
	#get_tree().quit()
	await get_tree().create_timer(WIN_TRANSITION_DELAY).timeout
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)


func _on_combo_failure() -> void:
	# If failure, show the explosion and play it
	animated_sprite_2d.visible = true
	
	# If your animation is named something specific, use play("explosion_name_here")
	# Otherwise, play() just plays the default one
	animated_sprite_2d.play() 


func _on_explosion_finished() -> void:
	# Once the explosion finishes its last frame, quit the game
	get_tree().quit()
