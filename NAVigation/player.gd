extends Area2D
@onready var lasersound: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var laser_scene: PackedScene
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _input(event: InputEvent) -> void:
	# Move the ship left and right following the mouse
	if event is InputEventMouseMotion:
		# Clamp keeps the player from moving off the edges of the screen
		global_position.x = clamp(event.position.x, 0, screen_size.x)

	# Shoot when the left mouse button is clicked
	if event.is_action_pressed("shoot"):
		shoot()

func shoot() -> void:
	if laser_scene:
		var laser = laser_scene.instantiate()
		# Spawn the laser at the Muzzle Marker2D's position
		laser.global_position = $Muzzle.global_position
		# Add the laser to the main scene tree
		lasersound.play()
		get_tree().root.add_child(laser)
