class_name Plug
extends Node2D

const this_scene: PackedScene = preload("res://cables/plug.tscn")

@export var type: PlugType = PlugType.Outlet

signal mouse_button(pressed: bool)

@onready var sprite: Sprite2D = $Sprite2D
@onready var area2d: Area2D = $Area2D

@onready var texture_outlet: Texture2D = load('res://cables/outlet.png')
@onready var texture_inlet: Texture2D = load('res://cables/inlet.png')

enum PlugType { Inlet = 1, Outlet = 2 }

static func new_plug(type: PlugType) -> Plug:
	var scene = this_scene.instantiate()
	scene.type = type
	return scene

var mouse_inside: bool = false

func _ready() -> void:
	match self.type:
		PlugType.Outlet: sprite.texture = texture_outlet
		PlugType.Inlet: sprite.texture = texture_inlet

func _on_area_2d_mouse_entered() -> void:
	self.mouse_inside = true

func _on_area_2d_mouse_exited() -> void:
	self.mouse_inside = false

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_button.emit(event.pressed)
