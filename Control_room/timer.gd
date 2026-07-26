extends Timer

@export var timer_time:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wait_time=timer_time
