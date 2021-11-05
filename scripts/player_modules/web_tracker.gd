extends Node2D

var cur_edge
var dist_to_extremes = { 'start': 0, 'end': 0 }
var cur_point

onready var tracker_handler = get_parent()
onready var body = tracker_handler.get_parent()
onready var spawner = get_node("/root/Main/Spawner")
onready var edges = get_node("/root/Main/Web/Edges")

func initialize(params = {}):
	var data = spawner.get_valid_random_position(params)
	
	body.set_position(data.pos)
	force_set_edge(data.edge)

func module_update(_dt):
	keep_positioned_on_web()

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
	
	cur_edge.m.entities.remove(body)
	cur_edge = null

func force_set_edge(e):
	cur_edge = e
	e.m.entities.add(body)

	tracker_handler.emit_signal("arrived_on_edge", e)

# the edge we were standing on has been removed (split by someone else jumping)
# so we only need to update our edge, not call anything else
func force_change_edge(e):
	force_set_edge(e)
	update_positions()

# the new edge might have a slightly different line
# so try all possibilities (start changed, end changed, direction reversed)
# and find the one with the least distance difference)
func update_positions():
	var vec = cur_edge.m.body.get_vec().normalized()
	var cur_pos = body.position
	var options = []
	options.resize(4)
	options[0] = cur_edge.m.body.start.position + dist_to_extremes.start*vec
	options[1] = cur_edge.m.body.start.position + dist_to_extremes.end*vec
	options[2] = cur_edge.m.body.end.position - dist_to_extremes.start*vec
	options[3] = cur_edge.m.body.end.position - dist_to_extremes.end*vec
	
	var best_option = null
	var least_change = INF
	for i in range(4):
		var change = (options[i] - cur_pos).length()
		if change < least_change:
			least_change = change
			best_option = options[i]
	
	body.set_position(best_option)
	recalculate_dist_to_extremes()

func keep_positioned_on_web():
	var new_pos
	
	if cur_point and is_instance_valid(cur_point):
		new_pos = cur_point.position
	
	elif cur_edge and is_instance_valid(cur_edge):
		recalculate_dist_to_extremes()
		
		new_pos = cur_edge.m.body.start.position + dist_to_extremes.start * cur_edge.m.body.get_vec().normalized()
	
	body.position = new_pos

func recalculate_dist_to_extremes():
	if not cur_edge:
		dist_to_extremes.start = 0
		dist_to_extremes.end = 0
		return
	
	var cur_pos = body.position
	dist_to_extremes.start = (cur_pos - cur_edge.m.body.start.position).length()
	dist_to_extremes.end = (cur_pos - cur_edge.m.body.end.position).length()

func arrived_on_edge(e):
	hard_remove_from_point()
	hard_remove_from_edge()
	
	cur_edge = e
	e.m.entities.add(body)
	body.set_position(e.m.body.get_closest_point(body).position)
	
	recalculate_dist_to_extremes()

	tracker_handler.emit_signal("arrived_on_edge", e)

func arrived_on_point(p):
	hard_remove_from_point()
	hard_remove_from_edge()
	
	cur_point = p
	p.add_entity(body)
	body.set_position(cur_point.position)
	
	recalculate_dist_to_extremes()

	tracker_handler.emit_signal("arrived_on_point", p)

func die():
	tracker_handler.disable()
	
	hard_remove_from_point()
	hard_remove_from_edge()
