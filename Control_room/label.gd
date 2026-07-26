extends Label

func _process(_delta: float) -> void:
	# Check if the global timer actually exists
	if GlobalTimer.timer != null:
		# Read the time left directly from the Autoload
		var time_left = GlobalTimer.timer.time_left
		
		# Format it to 1 decimal place
		text = "%.1f" % time_left
