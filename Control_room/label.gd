extends Label

@export var timer: Timer

func _process(_delta: float) -> void:
	# Always check if the timer is actually assigned in the Inspector first!
	if timer:
		# Get the time left
		var time_left_from_timer = timer.time_left
		
		# "%.1f" formats the number to have exactly 1 decimal place (e.g., "4.5")
		# If you want whole numbers only, change it to "%d"
		text = "%.1f" % time_left_from_timer
