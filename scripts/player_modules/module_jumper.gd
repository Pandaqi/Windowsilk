extends Node2D

var active : bool = false

onready var body = get_parent()
onready var edges = get_node("/root/Main/Web").edges

func _on_Input_move_vec(vec, dt):
	if not active: return
	
	var no_input = (vec.length() <= 0.03)
	if no_input: return
	
	body.set_rotation(vec.angle())

func _on_Input_button_press():
	start_jump()

func _on_Input_button_release():
	finish_jump()

func get_forward_vec():
	var rot = body.rotation
	return Vector2(cos(rot), sin(rot))

func start_jump():
	active = true

func finish_jump():
	active = false
	
	var dir = get_forward_vec()
	
	var exclude_bodies = []
	var edge = body.m.webtracker.get_current_edge()
	if edge: exclude_bodies = [edge]
	
	var point = body.m.webtracker.get_current_point()
	if point: 
		exclude_bodies.append(point)
		exclude_bodies += point.get_edges()
	
	var res = edges.shoot(body.global_position, dir, exclude_bodies, edge)
	
	body.m.webtracker.arrived_on_point(res.new_point)


