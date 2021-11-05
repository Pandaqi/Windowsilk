extends Node2D

const POINT_SNAP_RADIUS : float = 15.0
const ENTITY_OBSTRUCT_RADIUS : float = 30.0
const MIN_JUMP_DIST : float = 40.0

var edge_scene = preload("res://scenes/web/edge.tscn")

onready var points = get_node("../Points")
onready var web = get_parent()

var debug : bool = false

func shoot(params = {}):
	
	# a roundabout way of doing it, but Godot has nothing better?
	if not params.has('shooter'): params.shooter = null
	if not params.has('exclude'): params.exclude = []
	if not params.has('origin_edge'): params.origin_edge = null
	if not params.has('destroy'): params.destroy = false
	if not params.has('dont_create_new_edges'): params.dont_create_new_edges = false

	var data = {
		'failed': true,
		'created_something': false,
		
		'destroy': params.destroy,
		
		'from': params.from,
		'to': null,
		'dir': params.dir,
		'exclude': params.exclude,
		'shooter': params.shooter,
		
		'from_edge': params.origin_edge,
		'to_edge': null,
		'new_edge': null,
		
		'dont_create_new_edges': params.dont_create_new_edges
	}
	
	var res = shoot_raycast(data)
	if not res: return data
	
	snap_to_existing_point(data, 'from')
	snap_to_existing_point(data, 'to')
	
	res = does_edge_already_exist(data)
	if res: 
		if debug: print("Edge already exists; no need to create something new")
		data.failed = false
		data.to_edge = res
		return data
	
	# NOTE: also covers jumps between the same two points (as distance = 0 then)
	res = is_edge_too_short(data)
	if res: 
		if debug: print("Distance too small between start and end point of jump")
		return data
	
	res = is_shot_along_current_edge(data)
	if res:
		if debug: print("Shot along current edge; no need to create new stuff")
		data.failed = false
		return data
	
	res = is_too_similar_to_existing_edge(data)
	if res:
		if debug: print("Desired shot very similar to existing edge; so abort and use existing")
		data.failed = false
		data.to.point = res
		return data
	
	res = does_something_obstruct_arrival(data)
	if res:
		if debug: print("Can't go there; obstructing entity")
		return data
	
	create_new_points_and_edges_if_needed(data)
	destroy_points_and_edges_if_needed(data)
	
	data.failed = false
	data.created_something = true
	
	if data.dont_create_new_edges:
		data.destroy = false
	
	return data

func shoot_raycast(data):
	var space_state = get_world_2d().direct_space_state
	
	var dir = data.dir.normalized()
	var epsilon = dir*1.0
	
	var max_dist = 3000.0 # some high number, doesn't matter
	if data.shooter: max_dist = data.shooter.m.jumper.get_max_dist()
	
	var from = data.from + epsilon
	var to = from + dir*max_dist
	
	var col_layer = 1
	
	# check where we should land
	# the edges of the map always have bounds, so we always stop at the edge (if we hit nothing else)
	data.result = space_state.intersect_ray(from, to, data.exclude, col_layer)
	if not data.result: return false

	data.from = from
	data.to_edge = data.result.collider
	
	# DEBUGGING: is this actually a good idea/necessary?
	var compensate_for_imprecision = 0.5*dir*GlobalDict.cfg.line_thickness
	if data.to_edge.is_in_group("Bounds"): compensate_for_imprecision = Vector2.ZERO
	
	print("RAYCAST FOUND SOMETHING")
	
	data.to = data.result.position + compensate_for_imprecision
	return true

func snap_to_existing_point(data, key):
	var pos = data[key]
	data[key] = {
		'point': null,
		'pos': pos,
		'already_created': false
	}
	
	var snap_point = get_closest_point(pos)
	if not snap_point: return
	
	data[key] = {
		'point': snap_point,
		'pos': snap_point.position,
		'already_created': true
	}

func does_edge_already_exist(data):
	if not data.from.already_created: return false
	if not data.to.already_created: return false
	
	return data.to.point.get_edge_to(data.from.point)

func is_edge_too_short(data):
	if data.dont_create_new_edges: return false
	
	var dist_between_points = (data.to.pos - data.from.pos).length()
	return (dist_between_points < MIN_JUMP_DIST)

func is_shot_along_current_edge(data):
	var cur_edge = data.from_edge
	if not cur_edge: return false
	
	var edge_vec = cur_edge.m.body.get_vec()
	var actual_dir = (data.to.pos - data.from.pos).normalized()
	var dot = actual_dir.dot(edge_vec.normalized())
		
	if abs(dot) < 0.93: return false
	
	var target_point = cur_edge.m.body.end
	if dot < 0: target_point = cur_edge.m.body.start
	
	data.failed = false
	data.to.point = target_point
	
	return true

func does_something_obstruct_arrival(data):
	if not GlobalDict.cfg.entities_obstruct_each_other: return
	if not data.shooter: return false
	
	var obstructing_entity = get_closest_entity(data.to.pos, [data.shooter])
	if not obstructing_entity: return false
	
	return true

func is_too_similar_to_existing_edge(data):
	if data.dont_create_new_edges: return false
	
	var vec = (data.to.pos - data.from.pos).normalized()
	
	if data.from.point:
		var from_p = data.from.point
		for edge in from_p.get_edges():
			var edge_vec = edge.m.body.get_vec_starting_from(from_p).normalized()
			var dot = edge_vec.dot(vec)
			if dot < 0.93: continue
				
			if edge.m.body.start == from_p:
				return edge.m.body.end
			return edge.m.body.start
	
	if data.to.point:
		var to_p = data.to.point
		for edge in to_p.get_edges():
			var edge_vec = -edge.m.body.get_vec_starting_from(to_p).normalized()
			var dot = edge_vec.dot(vec)
			if dot < 0.93: continue
			
			return data.to.point
	
	return null

func create_new_points_and_edges_if_needed(data):
	if data.dont_create_new_edges: return
	
	if not data.from.already_created:
		data.from.point = points.create_at(data.from.pos)
		
		if not data.destroy:
			break_edge_in_two(data.from_edge, data.from.point, data)
	
	if not data.to.already_created:
		data.to.point = points.create_at(data.to.pos)
	
	# if we hit the _bounds_ of the level, we don't break anything
	# hence the check
	var hit_an_edge = (data.to_edge.is_in_group("Edges"))
	if hit_an_edge and not data.to.already_created: 
		break_edge_in_two(data.to_edge, data.to.point, data)
	
	# finally, create the new edge along the shooting line
	data.new_edge = create_between(data.from.point, data.to.point)

# destroy the point we just created, which in turn destroys all edges around itself
func destroy_points_and_edges_if_needed(data):
	if not data.destroy: return
	if not data.to.point: return
	
	if data.dont_create_new_edges:
		remove_existing(data.to_edge)
		return
	
	# NOTE: this is a bogus point with no live edges attached to it, so removing it only removes that point => left in for consistency
	if not data.from.already_created: points.remove_existing(data.from.point)
	points.remove_existing(data.to.point)

# find the points (that this edge connected) and any entities on them
# reconnect new edges to the old points, and transfer entities to the right one
func break_edge_in_two(edge, new_point, data):
	if not edge: return
	if edge.m.type.disallows_breaking() and data.destroy: return
	
	var pointA = edge.m.body.start
	var pointB = edge.m.body.end
	
	# @params => edge object, destroy orphans, keep entities alive
	# we need to keep all points and entities alive, because they will simply be redistributed over the _new_ edge we'll create now
	var data_to_transfer = remove_existing(edge, false, true)
	
	var edgeA = create_between(pointA, new_point)
	var edgeB = create_between(new_point, pointB)
	
	edgeA.m.type.set_to(data_to_transfer.type)
	edgeB.m.type.set_to(data_to_transfer.type)
	
	for e in data_to_transfer.entities:
		var vec_to_split_point = (e.position - new_point.position).normalized()
		var vecA = edgeA.m.body.get_vec_starting_from(new_point).normalized()
		var dotA = vecA.dot(vec_to_split_point)
		
		var vecB = edgeB.m.body.get_vec_starting_from(new_point).normalized()
		var dotB = vecB.dot(vec_to_split_point)
		
		if dotA > dotB:
			e.m.tracker.force_change_edge(edgeA)
		else:
			e.m.tracker.force_change_edge(edgeB)

func get_closest_point(pos : Vector2):
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = POINT_SNAP_RADIUS
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	
	var result = space_state.intersect_shape(query_params)
	if not result: return null
	
	var best_point = null
	var best_dist = INF
	for res in result:
		if not res.collider.is_in_group("Points"): continue
		
		var dist = (res.collider.position - pos).length()
		if dist < best_dist:
			best_dist = dist
			best_point = res.collider

	return best_point

func get_closest_entity(pos : Vector2, exclude = []):
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = ENTITY_OBSTRUCT_RADIUS
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	query_params.collision_layer = 2
	
	var result = space_state.intersect_shape(query_params)
	if not result: return null
	
	for res in result:
		if res.collider in exclude: continue
		return res.collider
	
	return null

func remove_existing(edge, destroy_orphan_points = true, keep_entities_alive = false):
	edge.m.body.start.remove_edge(edge, destroy_orphan_points)
	edge.m.body.end.remove_edge(edge, destroy_orphan_points)
	
	var entities = edge.m.entities.get_them()
	if not keep_entities_alive:
		for entity in entities:
			entity.m.status.die()
	
	edge.queue_free()
	
	return {
		'entities': entities,
		'type': edge.m.type.get_it()
	}

func create_between(a, b):
	var e = edge_scene.instance()
	add_child(e)
	e.m.body.set_extremes(a, b)
	
	a.add_edge(e)
	b.add_edge(e)
	
	if debug:
		print("Edge Created")
		print(e.m.body.get_center())
		print(e.m.body.col_shape.extents)
		print()
	
	if GlobalDict.cfg.debug_terrain_types:
		e.m.type.create_debug_terrain_type()
	
	return e

func get_random():
	var edges = get_tree().get_nodes_in_group("Edges")
	if edges.size() <= 0: return null
	return edges[randi() % edges.size()]

func get_random_pos_on_edge(margin = 0.0):
	var rand_edge = get_random()
	return rand_edge.m.body.get_random_pos_on_me(margin)
