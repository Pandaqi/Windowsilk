extends Node2D

var cur_edge
var dist_to_extremes = { 'start': 0, 'end': 0 }
var cur_point

var updating_disabled : bool = false

onready var body = get_parent()
onready var edges = get_node("/root/Main/Web/Edges")

func start_randomly():
	arrived_on_edge(edges.get_random())

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

# the edge we were standing on has been removed (split by someone else jumping)
# so we only need to update our edge, not call anything else
func force_change_edge(e):
	cur_edge = e
	e.add_entity(body)
	
	# the new edge might have a slightly different line
	# so try all possibilities (start changed, end changed, direction reversed)
	# and find the one with the least distance difference)
	var vec = cur_edge.get_vec().normalized()
	var cur_pos = body.position
	var options = []
	options.resize(4)
	options[0] = cur_edge.start.position + dist_to_extremes.start*vec
	options[1] = cur_edge.start.position + dist_to_extremes.end*vec
	options[2] = cur_edge.end.position - dist_to_extremes.start*vec
	options[3] = cur_edge.end.position - dist_to_extremes.end*vec
	
	var best_option = null
	var least_change = INF
	for i in range(4):
		var change = (options[i] - cur_pos).length()
		if change < least_change:
			least_change = change
			best_option = options[i]
	
	body.set_position(best_option)
	recalculate_dist_to_extremes()

func _physics_process(dt):
	keep_positioned_on_web()

func disable_updates():
	updating_disabled = true

func enable_updates():
	updating_disabled = false

func keep_positioned_on_web():
	if updating_disabled: return
	
	var cur_pos = body.position
	var new_pos
	
	if cur_point:
		new_pos = cur_point.position
	
	elif cur_edge:
		recalculate_dist_to_extremes()
		
		new_pos = cur_edge.start.position + dist_to_extremes.start * cur_edge.get_vec().normalized()
	
	body.position = new_pos

func recalculate_dist_to_extremes():
	if not cur_edge:
		dist_to_extremes.start = 0
		dist_to_extremes.end = 0
		return
	
	var cur_pos = body.position
	dist_to_extremes.start = (cur_pos - cur_edge.start.position).length()
	dist_to_extremes.end = (cur_pos - cur_edge.end.position).length()

func arrived_on_edge(e):
	hard_remove_from_point()
	hard_remove_from_edge()
	
	cur_edge = e
	e.add_entity(body)
	body.set_position(e.get_closest_point(body).position)
	
	recalculate_dist_to_extremes()

	body.m.mover.enter_edge(e)

func arrived_on_point(p):
	hard_remove_from_point()
	hard_remove_from_edge()
	
	cur_point = p
	p.add_entity(body)
	body.set_position(cur_point.position)
	
	recalculate_dist_to_extremes()
	
	body.m.mover.enter_point(p)
