extends Node2D

var vec : Vector2

onready var movement_handler = get_parent()
onready var body = movement_handler.get_parent()

var edges_visited = []

func initialize():
	pick_new_vec(null, null)

func module_update(dt):
	movement_handler.emit_signal("move_vec", vec, dt)

func set_vector(new_vec):
	vec = new_vec

func pick_new_vec(point, _edge):
	var rot = 2*PI*randf()
	vec = Vector2(cos(rot), sin(rot))
	
	if not point: return
	
	var edges = point.m.edges.get_them()
	var point_has_only_one_route = (edges.size() == 1)
	if point_has_only_one_route:
		var vec_over_route = edges[0].m.body.get_vec_starting_from(point)
		vec = vec_over_route.normalized()
		return
	
	var candidates = []
	if movement_handler.has_fleeing_behavior():
		candidates = point.m.edges.get_without_threat(body)
	elif movement_handler.has_chasing_behavior():
		candidates = point.m.edges.get_with_food(body)
	
	# discourage backtracking
	var candidates_copy = candidates + []
	for i in range(candidates_copy.size()-1,-1,-1):
		var c = candidates_copy[i]
		if c in edges_visited:
			candidates_copy.remove(i)
	
	if candidates_copy.size() > 0:
		var rand_candidate = candidates_copy[randi() % candidates_copy.size()]
		vec = rand_candidate.m.body.get_vec_starting_from(point).normalized()
		return
	
	if candidates.size() > 0:
		var rand_candidate = candidates[randi() % candidates.size()]
		vec = rand_candidate.m.body.get_vec_starting_from(point).normalized()

func pick_opposite_vec():
	vec = -vec

func _on_Tracker_arrived_on_edge(e):
	var already_has_chosen_dir = (vec.length() >= 0.03)
	if already_has_chosen_dir: return
	
	if not (e in edges_visited):
		edges_visited.append(e)
	
	# hacky fail-safe to prevent this array from becoming HUGE!
	if edges_visited.size() >= 20:
		edges_visited = []
	
	pick_new_vec(null, e)

func _on_Tracker_arrived_on_point(p):
	pick_new_vec(p, null)
