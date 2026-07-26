extends Node2D

@export var asteroid_scene: PackedScene
var screen_size: Vector2
@onready var direction_indicator: Node2D = $"Direction indicator"

# --- Variables for the confused indicator ---
var target_rotation: float = 0.0
var indicator_speed: float = 2.0 

func _ready() -> void:
	screen_size = get_viewport_rect().size
	print("----- DEBUG START -----")
	print("MAIN: Game started. Screen size is: ", screen_size)
	
	# Check if you remembered to drag the scene into the Inspector
	if asteroid_scene == null:
		print("ERROR: asteroid_scene is EMPTY! Drag Asteroid.tscn into the Main node's Inspector.")
	else:
		print("MAIN: Asteroid scene is loaded and ready.")

func _process(delta: float) -> void:
	# 1. Have a very small chance (2%) every frame to pick a completely new direction
	if randf() < 0.02:
		# Pick a random angle in a full 360 circle (-PI to PI radians)
		target_rotation = randf_range(-PI, PI)
	
	# 2. Smoothly swing the indicator toward the target angle over time
	# lerp_angle is magic: it smoothly transitions between angles taking the shortest path
	direction_indicator.rotation = lerp_angle(direction_indicator.rotation, target_rotation, indicator_speed * delta)

func _on_spawn_timer_timeout() -> void:
	print("MAIN: SpawnTimer just ticked!")
	
	if asteroid_scene:
		var asteroid = asteroid_scene.instantiate()
		asteroid.scale = Vector2(0.1, 0.1)
		
		var random_x = randf_range(20, screen_size.x - 20)
		asteroid.global_position = Vector2(random_x, 0)
		
		add_child(asteroid)
		print("MAIN: Asteroid spawned successfully at: ", asteroid.global_position)
	else:
		print("ERROR: Timer ticked, but cannot spawn because asteroid_scene is null.")
