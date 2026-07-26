extends CPUParticles2D

# NEW: Reference to the audio player child node
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# Force it to emit as soon as it spawns
	emitting = true
	
	# NEW: Play the sound the moment the explosion appears
	audio_player.play()

func _process(_delta: float) -> void:
	# THE FIX: Wait for both the particles to finish AND the sound to stop!
	if not emitting and not audio_player.playing:
		queue_free()
