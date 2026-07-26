extends Area2D

@export var speed: float = 600.0

func _process(delta: float) -> void:
	# Move the laser straight up
	position.y -= speed * delta

# Connect this signal from the VisibleOnScreenNotifier2D via the Node tab
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Destroys the laser when it leaves the screen
