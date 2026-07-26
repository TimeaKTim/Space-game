extends CPUParticles2D

func _ready() -> void:
	# Force it to emit as soon as it spawns
	emitting = true

func _process(delta: float) -> void:
	# If the particles have finished their lifetime, delete the node
	if not emitting:
		queue_free()
