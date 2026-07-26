class_name Plug
extends Sprite2D

@export var texture_outlet: Texture2D
@export var texture_outlet_highlighted: Texture2D
@export var texture_inlet: Texture2D
@export var texture_inlet_highlighted: Texture2D

@onready var label = $Label

var text: String:
	set(value):
		label.text = value
	get:
		return label.text

enum PlugType { Inlet = 1, Outlet = 2 }

@export var type: PlugType = PlugType.Outlet:
	set(value):
		type = value
		__assign_texture()
		__assign_radius()

@export var highlighted: bool = false:
	set(value):
		highlighted = value
		__assign_texture()

@export var radius: int

func __assign_texture() -> void:
	match type:
		PlugType.Inlet when highlighted: texture = texture_inlet_highlighted
		PlugType.Outlet when highlighted: texture = texture_outlet_highlighted
		PlugType.Inlet: texture = texture_inlet
		PlugType.Outlet: texture = texture_outlet

func __assign_radius() -> void:
	if self.texture != null:
		radius = ceil(self.texture.get_size().x / 2)

func _ready() -> void:
	__assign_texture()
	__assign_radius()
