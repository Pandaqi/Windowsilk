extends KinematicBody2D

var edges = []
var entities = []

const COLOR : Color = Color(1,1,1)

onready var points = get_node("/root/Main/Web/Points")
onready var col_shape = get_node("CollisionShape2D").shape

func _ready():
	col_shape.radius = GlobalDict.cfg.line_thickness

func move(vec, _dt):
	move_and_slide(vec)
	
	# TO DO: maybe add a general "status" module to edges, so we can just call "update" on that and it handles this?
	for e in edges:
		e.m.body.update_body()
		e.m.drawer.update_visuals()
		e.m.entities.update_positions()

func add_entity(e):
	entities.append(e)

func remove_entity(e):
	entities.erase(e)

func get_entities():
	return entities

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
	draw_circle(Vector2.ZERO, col_shape.radius, COLOR)
