extends Node

# We create the Timer node entirely in code
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 300.0 # Set your total game time here (e.g., 300 seconds = 5 minutes)
	timer.one_shot = true
	timer.autostart = true
	
	# Add the timer to this global script
	add_child(timer)
	
	# Connect the timeout signal
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	print("GLOBAL TIME IS UP!")
	# You can add logic here to jump to a "Game Over" scene!
	# get_tree().change_scene_to_file("res://GameOver.tscn")
