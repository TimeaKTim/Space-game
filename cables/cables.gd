extends Node2D

const plug_scene: PackedScene = preload("res://cables/plug.tscn")
const wire_scene: PackedScene = preload("res://cables/wire.tscn")

@onready var collisionshape2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var background: Sprite2D = $Sprite2D

var plugs: Array[Plug] = []
var wires: Array[Wire] = []
var from: int = -1
var to: int = -1
var mouse: int = -1

func start_selection(idx: int) -> void:
	wires[idx].init(plugs[idx].position)
	from = idx
	to = -1

func end_selection() -> void:
	if from == -1:
		return
	
	if to == -1:
		wires[from].clear()
	
	from = -1
	to = -1

func _ready() -> void:
	# set collision shape to viewport size (fullscreen)
	var vp_size := get_viewport().get_visible_rect().size
	self.collisionshape2d.position = vp_size / 2
	(self.collisionshape2d.shape as RectangleShape2D).size = get_viewport().get_visible_rect().size
	
	# helpers to layout plugs
	var padding := Vector2(100, 100)
	var inner := Rect2(Vector2.ZERO, vp_size)
	inner.position += padding
	inner.size -= 2 * padding
	
	# spawn and place plugs
	var num_plugs := 5
	for i in range(num_plugs):
		var plug: Plug = plug_scene.instantiate()
		plug.type = Plug.PlugType.Outlet
		plug.translate(Vector2(
			inner.position.x,
			inner.position.y + inner.size.y / (num_plugs - 1) * i
		))
		plug.scale = Vector2.ONE * 100 / 256
		plugs.append(plug)
		add_child(plug)
	for i in range(num_plugs):
		var plug: Plug = plug_scene.instantiate()
		plug.type = Plug.PlugType.Inlet
		plug.translate(Vector2(
			inner.position.x + inner.size.x,
			inner.position.y + inner.size.y / (num_plugs - 1) * i
		))
		plug.scale = Vector2.ONE * 100 / 256
		plugs.append(plug)
		add_child(plug)
	for i in range(num_plugs):
		var new_wire: Wire = wire_scene.instantiate()
		self.wires.append(new_wire)
		add_child(new_wire)

func _process(_delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	
	# check to see if mouse is in one of the plugs
	self.mouse = -1
	for idx in range(len(self.plugs)):
		var plug := self.plugs[idx]
		if Geometry2D.is_point_in_circle(mouse_pos, plug.position, plug.radius * max(plug.scale.x, plug.scale.y)):
			self.mouse = idx
			break
	
	# either drag wire end to mouse or snap to plug
	self.to = -1
	if self.from != -1:
		if self.mouse != -1 and self.plugs[self.mouse].type == Plug.PlugType.Inlet:
			self.wires[self.from].to = self.plugs[self.mouse].position
			self.to = self.mouse
		else:
			self.wires[self.from].to = mouse_pos

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if self.mouse != -1 and self.plugs[self.mouse].type == Plug.PlugType.Outlet:
				self.start_selection(self.mouse)
		else:
			self.end_selection()
