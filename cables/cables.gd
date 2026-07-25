extends Node2D

var wire: PackedScene = preload("res://cables/wire.tscn")

@onready var collisionshape2d: CollisionShape2D = $Area2D/CollisionShape2D

var plugs: Array[Plug] = []
var wires: Array[Wire] = []
var from: int = -1
var to: int = -1

func add_plug(plug: Plug):
	add_child(plug)
	plugs.append(plug)
	var idx = len(plugs) - 1
	match plug.type:
		Plug.PlugType.Outlet:
			plug.mouse_button.connect(func(pressed): if pressed:
				self.start_selection(idx)
			)
		Plug.PlugType.Inlet:
			plug.mouse_button.connect(func(pressed): if not pressed:
				self.cancel_selection()
			)

func start_selection(idx: int):
	self.wires[idx].from = self.plugs[idx].position
	self.wires[idx].to = self.plugs[idx].position
	self.from = idx
	self.to = -1

func cancel_selection():
	self.wires[self.from].clear()
	self.from = -1
	self.to = -1

func end_selection():
	self.from = -1
	self.to = -1

func _ready() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	self.collisionshape2d.position = vp_size / 2
	(self.collisionshape2d.shape as RectangleShape2D).size = get_viewport().get_visible_rect().size
	
	var vp = get_viewport().get_visible_rect()
	
	var padding = Vector2(100, 100)
	var inner = Rect2(vp)
	inner.position += padding
	inner.size -= 2 * padding
	
	var num_plugs = 5
	
	for i in range(num_plugs):
		var plug = Plug.new_plug(Plug.PlugType.Outlet)
		plug.translate(Vector2(
			inner.position.x,
			inner.position.y + inner.size.y / (num_plugs - 1) * i
		))
		plug.scale = Vector2.ONE * 100 / 256
		self.add_plug(plug)
	
	for i in range(num_plugs):
		var plug = Plug.new_plug(Plug.PlugType.Inlet)
		plug.translate(Vector2(
			inner.position.x + inner.size.x,
			inner.position.y + inner.size.y / (num_plugs - 1) * i
		))
		plug.scale = Vector2.ONE * 100 / 256
		self.add_plug(plug)
	
	for i in range(num_plugs):
		var new_wire = wire.instantiate()
		self.wires.append(new_wire)
		add_child(new_wire)

func _process(_delta: float) -> void:
	var _to = -1
	if self.from != -1:
		var pos = get_local_mouse_position()
		for idx in range(len(self.plugs)):
			var plug = self.plugs[idx]
			if plug.type == Plug.PlugType.Inlet and plug.mouse_inside:
				_to = idx
				pos = plug.position
				break
		to = _to
		self.wires[self.from].to = pos

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		print("released to = ", to)
		if to == -1:
			self.cancel_selection()
		else:
			self.end_selection()
