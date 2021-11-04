extends StaticBody2D

var edges = []
var entities = []

const RADIUS : float = 10.0
const COLOR : Color = Color(1,1,1)

func add_entity(e):
	entities.append(e)

func remove_entity(e):
	entities.erase(e)

func add_edge(e):
	edges.append(e)

func remove_edge(e):
	edges.erase(e)

func get_edges():
	return edges

func get_edge_to(p):
	for e in edges:
		if e.m.body.start == p: return e
		if e.m.body.end == p: return e

func has_edge(e):
	return (e in edges)

func find_edge_closest_to_vec(vec : Vector2):
	var best = null
	var best_dot = -INF
	
	for e in edges:
		var edge_vec = e.m.body.get_vec_starting_from(self)
		var dot = edge_vec.normalized().dot(vec)
		if dot <= best_dot: continue
		
		best_dot = dot
		best = e
	
	return best

func _draw():
	draw_circle(Vector2.ZERO, RADIUS, COLOR)
