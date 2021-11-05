extends Node2D

var vec : Vector2

onready var movement_handler = get_parent()
onready var body = movement_handler.get_parent()

func initialize():
	pick_new_vec(null, null)

func module_update(dt):
	movement_handler.emit_signal("move_vec", vec, dt)

func set_vector(new_vec):
	vec = new_vec

func pick_new_vec(point, edge):
	var rot = 2*PI*randf()
	vec = Vector2(cos(rot), sin(rot))
	
	if not point: return
	
	var point_has_only_one_route = (point.get_edges().size() == 1)
	if point_has_only_one_route:
		var vec_over_route = point.get_edges()[0].m.body.get_vec_starting_from(point)
		vec = vec_over_route.normalized()
		return
	
	var candidates = []
	if movement_handler.has_fleeing_behavior():
		candidates = point.get_edges_without_threat(body)
	elif movement_handler.has_chasing_behavior():
		candidates = point.get_edges_with_food(body)
	
	if candidates.size() > 0:
		var rand_candidate = candidates[randi() % candidates.size()]
		vec = rand_candidate.m.body.get_vec_starting_from(point).normalized()

func _on_Tracker_arrived_on_edge(e):
	var already_has_chosen_dir = (vec.length() >= 0.03)
	if already_has_chosen_dir: return
	
	pick_new_vec(null, e)

func _on_Tracker_arrived_on_point(p):
	pick_new_vec(p, null)
