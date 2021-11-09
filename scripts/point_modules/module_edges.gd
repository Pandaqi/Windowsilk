extends Node2D

onready var points = get_node("/root/Main/Web/Points")
onready var body = get_parent()

var edges = []

func add(e):
	edges.append(e)

func remove(e, destroy_orphan_points = true):
	edges.erase(e)
	
	if destroy_orphan_points and is_orphan():
		points.remove_existing(body)

func is_orphan():
	return (edges.size() <= 0)

func update_edges():
	for e in edges:
		e.m.status.check()

func get_them():
	return edges

func get_to(p):
	for e in edges:
		if e.m.body.start == p: return e
		if e.m.body.end == p: return e

func has_specific(e):
	return (e in edges)

func find_closest_to_vec(vec : Vector2):
	var best = null
	var best_dot = -INF
	
	for e in edges:
		var edge_vec = e.m.body.get_vec_starting_from(body)
		var dot = edge_vec.normalized().dot(vec)
		if dot <= best_dot: continue
		
		best_dot = dot
		best = e
	
	return best

func get_without_threat(body):
	var arr = []
	for e in edges:
		if e.m.entities.has_threat_to(body): continue
		arr.append(e)
	return arr

func get_with_food(body):
	var arr = []
	for e in edges:
		if not e.m.entities.has_food_for(body): continue
		arr.append(e)
	return arr
