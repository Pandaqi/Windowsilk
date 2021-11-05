extends StaticBody2D

var edges = []
var entities = []

const RADIUS : float = 10.0
const COLOR : Color = Color(1,1,1)

onready var points = get_node("/root/Main/Web/Points")

func add_entity(e):
	entities.append(e)

func remove_entity(e):
	entities.erase(e)

func add_edge(e):
	edges.append(e)

func remove_edge(e, destroy_orphan_points = true):
	edges.erase(e)
	
	var is_orphan = (edges.size() <= 0)
	if destroy_orphan_points and is_orphan:
		points.remove_existing(self)

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

# TO DO: Should probably be a function on edge.gd script => "has_threat(body)"
# Also, lots of overlap, but is it worth it to merge these functions?
func get_edges_without_threat(body):
	var arr = []
	for e in edges:
		if e.m.entities.has_threat_to(body): continue
		arr.append(e)
	return arr

func get_edges_with_food(body):
	var arr = []
	for e in edges:
		if not e.m.entities.has_food_for(body): continue
		arr.append(e)
	return arr

func _draw():
	draw_circle(Vector2.ZERO, RADIUS, COLOR)
