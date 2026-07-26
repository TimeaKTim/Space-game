extends Node2D

const zap_scene: PackedScene = preload("res://cables/zap.tscn")
const plug_scene: PackedScene = preload("res://cables/plug.tscn")
const wire_scene: PackedScene = preload("res://cables/wire.tscn")

var plugs: Array[Plug] = []
var wires: Array[Wire] = []
var from: int = -1
var to: int = -1
var mouse: int = -1

var objective: Dictionary[int, int] = {}
var connections: Dictionary[int, int] = {}

func start_selection(idx: int) -> void:
	wires[idx].init(plugs[idx].position)
	from = idx
	to = -1

func end_selection() -> void:
	if from == -1:
		return
	
	if to == -1:
		wires[from].clear()
	
	if from not in objective or objective[from] != to:
		wires[from].clear()
		
		print("zap")
		var zap_effect: Zap = zap_scene.instantiate()
		zap_effect.emitting = true
		plugs[to].add_child(zap_effect)
	
	from = -1
	to = -1

func _ready() -> void:
	# list plugs
	for child in get_children():
		if child is Plug:
			self.plugs.append(child)
	
	# add as many wires
	for i in range(len(self.plugs)):
		var new_wire: Wire = wire_scene.instantiate()
		self.wires.append(new_wire)
		add_child(new_wire)

func _process(_delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	
	# check to see if mouse is in one of the plugs...
	self.mouse = -1
	for idx in range(len(self.plugs)):
		var plug := self.plugs[idx]
		if Geometry2D.is_point_in_circle(mouse_pos, plug.position, plug.radius * max(plug.scale.x, plug.scale.y)):
			self.mouse = idx
		# unhighlight everything while we're at it
		plug.highlighted = false
	
	# ...if it is, highlight it
	if self.mouse != -1:
		self.plugs[self.mouse].highlighted = true
	
	# either drag wire end to mouse or snap to plug
	self.to = -1
	if self.from != -1:
		if self.mouse != -1 and self.plugs[self.mouse].type == Plug.PlugType.Inlet:
			self.wires[self.from].to = self.plugs[self.mouse].position
			self.to = self.mouse
		else:
			self.wires[self.from].to = mouse_pos
	
	# get the wire closests to the cursor
	var closest_idx := -1
	var closest_dist := 999999
	for idx in range(len(wires)):
		var wire = wires[idx]
		if wire.from != wire.to:
			var dst = Geometry2D.get_closest_point_to_segment(mouse_pos, wire.from, wire.to).distance_to(mouse_pos)
			if dst < closest_dist:
				closest_idx = idx
				closest_dist = dst
	
	# if there is one and it's not too far, make it blink and everything else not blink
	if closest_dist > 50:
		closest_idx = -1
	
	for idx in range(len(wires)):
		wires[idx].blinking = (idx == closest_idx)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if self.mouse != -1 and self.plugs[self.mouse].type == Plug.PlugType.Outlet:
				self.start_selection(self.mouse)
		else:
			self.end_selection()
