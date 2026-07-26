extends Node2D

func _on_button_pressed() -> void:
	# 1. Reset the Alphabet
	TranslationManager.reset_alphabet()
	
	# 2. Reset the Timer
	GlobalTimer.reset_timer()
	
	# 3. Change the Scene
	get_tree().change_scene_to_file("res://Control_room/control_room.tscn")
