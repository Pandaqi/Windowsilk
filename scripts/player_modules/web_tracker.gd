extends Node2D

var cur_edge
var cur_point

onready var body = get_parent()

func get_current_edge():
	return cur_edge

func get_current_point():
	return cur_point

func hard_remove_from_point():
	if not cur_point: return
	
	cur_point.remove_entity(body)
	cur_point = null

func hard_remove_from_edge():
	if not cur_edge: return
	
	cur_edge.remove_entity(body)
	cur_edge = null

func arrived_on_edge(e):
	hard_remove_from_point()
	hard_remove_from_edge()
	
	cur_edge = e
	e.add_entity(body)
	body.set_position(e.get_closest_point(body).position)

	body.m.mover.enter_edge(e)

func arrived_on_point(p):
	hard_remove_from_point()
	hard_remove_from_edge()
	
	cur_point = p
	p.add_entity(body)
	body.set_position(cur_point.position)
	
	body.m.mover.enter_point(p)
