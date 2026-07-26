extends Area2D

signal shot_down

@export var speed: float = 250.0
@export var explosion_scene: PackedScene 

func _process(delta: float) -> void:
	position.y += speed * delta
	
	# Despawn if it goes off the bottom of the screen
	if global_position.y > 900:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Checking for both lowercase and uppercase just in case!
	if area.is_in_group("player") or area.is_in_group("Player"):
		area.queue_free() 
		explode()         
		print("Game Over!")
		
	elif area.is_in_group("laser") or area.is_in_group("Laser"):
		area.queue_free() 
		explode()         
		shot_down.emit()

func explode() -> void:
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		
		# THE FIX: call_deferred prevents the physics engine from crashing!
		get_parent().call_deferred("add_child", explosion)
		
	queue_free()
