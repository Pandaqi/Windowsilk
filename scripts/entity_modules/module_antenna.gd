extends Node2D

var antennas = {}

var color : Color
var thickness : float = 2.0
var max_dist : float = 10.0

const WOBBLE_VELOCITY : float = 10.0
const WOBBLE_DAMPING : float = 0.92

onready var visuals = get_parent()

func initialize(data):
	load_antenna_data(data)

func load_antenna_data(data):
	var scene = load("res://scenes/antennas/" + data.type + '.tscn').instance()
	for child in scene.get_children():
		var key = child.name
		
		scene.remove_child(child)
		self.add_child(child)
		
		if data.has('scale_offset'):
			child.position.y *= data.scale_offset
		
		var length = child.get_node("Offset").position.length()
		
		antennas[key] = { 
			'start': child,
			'length': length,
			'vec': get_random_vec(),
			'end': Vector2.ZERO 
		}

	if data.has('max_dist'):
		max_dist = data.max_dist
	
	if data.has('color') and (data.color is Color):
		color = data.color
	
	if data.has('scale_thickness'):
		thickness *= data.scale_thickness
	
	reset()

func get_random_vec():
	var rot = 2*PI*randf()
	return Vector2(cos(rot), sin(rot))

func reset():
	for key in antennas:
		var antenna = antennas[key]
		antenna.ideal_pos = antenna.start.get_node("Offset").global_position
		antenna.end = antenna.ideal_pos 

func _physics_process(dt):
	simulate_antennas(dt)
	update()

func simulate_antennas(dt):
	for key in antennas:
		var antenna = antennas[key]
		
		var start_pos = antenna.start.global_position
		var ideal_pos = antenna.start.get_node("Offset").global_position
		antenna.ideal_pos = ideal_pos
		
		var vec_to_ideal_pos = (ideal_pos - antenna.end)
		var dist_to_ideal_pos = (ideal_pos - antenna.end).length()
		if dist_to_ideal_pos > max_dist:
			antenna.end = ideal_pos - vec_to_ideal_pos.normalized()*max_dist
		
		var move_vec = vec_to_ideal_pos * WOBBLE_VELOCITY * dt
		
		antenna.vec += move_vec
		antenna.end += antenna.vec
		
		antenna.vec *= WOBBLE_DAMPING

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	
	var r = q0.linear_interpolate(q1, t)
	return r

# TO DO: Draw an ARC instead, or at least some curve
func _draw():
	for key in antennas:
		var antenna = antennas[key]
		
		var start = antenna.start.position
		var end = to_local(antenna.end)
		#var ideal_pos = to_local(antenna.ideal_pos)
		
		var control = start + Vector2.RIGHT*5
		
		var point_list = build_point_list(start, control, end)
		
		draw_polyline(point_list, color, thickness)

# NOTE: THe "ideal position" is used as the control point for the bezier curve
func build_point_list(start, control, end):
	var num_points = 7
	var list = []
	
	for i in range(num_points):
		var factor = i / float(num_points - 1)
		list.append(quadratic_bezier(start, control, end, factor))
	
	return list
