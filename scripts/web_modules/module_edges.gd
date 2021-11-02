extends Node2D

const POINT_SNAP_RADIUS : float = 15.0

var edge_scene = preload("res://scenes/web/edge.tscn")

onready var points = get_node("../Points")
onready var web = get_parent()

var debug : bool = true

func shoot(from : Vector2, dir : Vector2, exclude = [], origin_edge = null):
	var space_state = get_world_2d().direct_space_state
	
	dir = dir.normalized()
	var epsilon = dir*1.0
	var to = from + dir*3000.0
	
	var col_layer = 1
	
	# check where we should land
	# the edges of the map always have bounds, so we always stop at the edge (if we hit nothing else)
	var result = space_state.intersect_ray(from + epsilon, to, exclude, col_layer)
	if not result: 
		print("SOMETHING WENT WRONG; there should always be a result")
		return
	
	# create a point where we came from
	# if this is awfully close to another point, just snap to that one
	# (much cleaner in all ways)
	var from_point
	var create_from_point = true
	var snappable_from_point = get_closest_point(from)
	if snappable_from_point:
		from_point = snappable_from_point
		create_from_point = false
	
	# similar idea: create a new point, or snap to an existing one
	var create_new_point = true
	var new_point
	var snappable_new_point = get_closest_point(result.position)
	if snappable_new_point:
		create_new_point = false
		new_point = snappable_new_point
	
		if not create_from_point:
			var existing_edge = new_point.get_edge_to(from_point)
			if existing_edge:
				return {
					'new_edge': existing_edge,
					'new_point': new_point
				}
	
	if create_from_point:
		from_point = points.create_at(from)
		break_edge_in_two(origin_edge, from_point)
	
	if create_new_point:
		new_point = points.create_at(result.position)
	
	var hit_an_edge = (result.collider.is_in_group("Edges"))
	if hit_an_edge: break_edge_in_two(result.collider, new_point)
	
	# finally, create the new edge along the shooting line
	var new_edge = create_between(from_point, new_point)
	
	return {
		'new_edge': new_edge,
		'new_point': new_point
	}


# find the points (that this edge connected) and any entities on them
# reconnect new edges to the old points, and transfer entities to the right one
func break_edge_in_two(edge, new_point):
	if not edge: return
	
	var pointA = edge.start
	var pointB = edge.end
	
	var entities = remove_existing(edge)
	
	var e = create_between(pointA, new_point)
	e.try_adding_entities(entities)
	
	e = create_between(new_point, pointB)
	e.try_adding_entities(entities)

func get_closest_point(pos : Vector2):
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = POINT_SNAP_RADIUS
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	
	var result = space_state.intersect_shape(query_params)
	if not result: return null
	
	for res in result:
		if not res.collider.is_in_group("Points"): continue
		return res.collider
	
	return null

func remove_existing(edge):
	edge.start.remove_edge(edge)
	edge.end.remove_edge(edge)
	
	var entities = edge.get_entities_on_me()
	edge.queue_free()
	return entities

func create_between(a, b):
	var e = edge_scene.instance()
	web.add_child(e)
	e.set_extremes(a, b)
	
	a.add_edge(e)
	b.add_edge(e)
	
	if debug:
		print("Edge Created")
		print(e.get_center())
		print(e.col_shape.extents)
		print()
	
	return e
