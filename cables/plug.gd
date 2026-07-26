class_name Plug
extends Sprite2D

@onready var texture_outlet: Texture2D = load('res://cables/outlet.png')
@onready var texture_inlet: Texture2D = load('res://cables/inlet.png')

enum PlugType { Inlet = 1, Outlet = 2 }

@export var type: PlugType = PlugType.Outlet:
	set(value):
		type = value
		__assign_texture()
		__assign_radius()

@export var radius: int

func __assign_texture() -> void:
	match type:
		PlugType.Inlet: texture = texture_inlet
		PlugType.Outlet: texture = texture_outlet

func __assign_radius() -> void:
	if self.texture != null:
		radius = ceil(self.texture.get_size().x / 2)

func _ready() -> void:
	__assign_texture()
	__assign_radius()
