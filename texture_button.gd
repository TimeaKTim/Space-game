extends TextureButton

@export var Scene: String

func _on_pressed() -> void:
	if Scene != "":
		get_tree().change_scene_to_file(Scene)
