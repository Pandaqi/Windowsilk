extends Node2D

onready var spawner = get_node("/root/Main/Spawner")

onready var tracker_handler = get_parent()
onready var body = tracker_handler.get_parent()

onready var area = $Area2D

var cur_edge
var cur_point

func is_active():
	return (tracker_handler.active_module == self)

func initialize(params):
	params.avoid_web = true
	
	var data = spawner.get_valid_random_position(params)
	var pos = data.pos
	
	if params.has('fixed_pos'):
		pos = params.fixed_pos
	
	body.set_rotation(2*PI*randf())
	body.set_position(pos)

func get_current_edge():
	if not is_instance_valid(cur_edge):
		cur_edge = null
	
	if not cur_edge:
		for b in area.get_overlapping_bodies():
			if b.is_in_group("Edges"):
				cur_edge = b
				break
		
	return cur_edge

func get_current_point():
	if not is_instance_valid(cur_point):
		cur_point = null
	
	if not cur_point:
		for b in area.get_overlapping_bodies():
			if b.is_in_group("Points"):
				cur_point = b
				break
	
	return cur_point

func arrived_on_edge(e):
	cur_edge = e
	tracker_handler.switcher.arrived_on_edge(e)
	
	paint_trail()
	handle_getting_stuck()

func paint_trail():
	body.m.trail.paint_specific_edge(cur_edge)

func handle_getting_stuck():
	body.m.silkreader.check_if_were_stuck(cur_edge)

func arrived_on_point(p):
	cur_point = p
	tracker_handler.switcher.arrived_on_point(p)

func _on_Area2D_body_entered(other_body):
	if not is_active(): return
	
	if other_body.is_in_group("Edges"):
		arrived_on_edge(other_body)
	elif other_body.is_in_group("Points"):
		arrived_on_point(other_body)

func _on_Area2D_body_exited(other_body):
	if not is_active(): return
	
	if other_body == cur_edge:
		cur_edge = null
	elif other_body == cur_point:
		cur_point = null

func remove_from_all():
	cur_point = null
	cur_edge = null
