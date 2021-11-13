extends Node2D

var POINT_SNAP_RADIUS : float = 25.0
var ENTITY_OBSTRUCT_RADIUS : float = 30.0
var MIN_JUMP_DIST : float = 40.0

const TRIPLE_RAYCAST_OFFSET : float = 9.0

var edge_scene = preload("res://scenes/web/edge.tscn")

onready var points = get_node("../Points")
onready var web = get_parent()

var debug : bool = false

func _ready():
	POINT_SNAP_RADIUS = (GlobalDict.cfg.line_thickness + 5.0)
	MIN_JUMP_DIST = POINT_SNAP_RADIUS * 2
	ENTITY_OBSTRUCT_RADIUS = POINT_SNAP_RADIUS

func shoot(params = {}):
	
	# a roundabout way of doing it, but Godot has nothing better?
	if not params.has('shooter'): params.shooter = null
	if not params.has('exclude'): params.exclude = []
	if not params.has('origin_edge'): params.origin_edge = null
	if not params.has('destroy'): params.destroy = false
	if not params.has('dont_create_new_edges'): params.dont_create_new_edges = false
	if not params.has('max_dist'): params.max_dist = 5000.0

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
		
		'max_dist': params.max_dist,
		
		'dont_create_new_edges': params.dont_create_new_edges
	}
	
	# We shoot three raycasts: one straight ahead, one just to the left, one just to the right
	# This prevents us from _narrowly_ missing an obvious landing spot
	var res = shoot_three_raycasts(data)
	if not res: 
		return data
	
	snap_to_existing_point(data, 'from')
	snap_to_existing_point(data, 'to')
	
	# snapping and three raycasts can change the actual dir of the edge
	# so recalculate here
	data.dir = (data.to.pos - data.from.pos).normalized()
	
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

func shoot_three_raycasts(data):
	var froms = [data.from]
	var old_from = data.from
	var ortho_dir = data.dir.normalized().rotated(0.5*PI)
	var offset = TRIPLE_RAYCAST_OFFSET
	
	var res = shoot_raycast(data)
	
	data.from = old_from + ortho_dir * offset
	froms.append(data.from)
	var resL = shoot_raycast(data)
	
	data.from = old_from - ortho_dir * offset
	froms.append(data.from)
	var resR = shoot_raycast(data)
	
	var results = [res, resL, resR]
	var best_result = -1
	var best_dist = INF
	
	for i in range(3):
		if not results[i]: continue
		
		var dist = (results[i].collider.position - old_from).length()
		if dist < best_dist:
			best_dist = dist
			best_result = i
	
	if best_result < 0: return false

	data.result = results[best_result]
	data.from = froms[best_result]
	data.to_edge = data.result.collider
	
	# DEBUGGING: is this actually a good idea/necessary?
	var compensate_for_imprecision = 0.5*data.dir.normalized()*GlobalDict.cfg.line_thickness
	if data.to_edge.is_in_group("Bounds"): compensate_for_imprecision = Vector2.ZERO

	data.to = data.result.position + compensate_for_imprecision
	
	return true

func shoot_raycast(data):
	var space_state = get_world_2d().direct_space_state
	
	var dir = data.dir.normalized()
	var epsilon = dir*1.0

	var from = data.from + epsilon
	var to = from + dir*data.max_dist
	
	var col_layer = 1 + 8
	
	# check where we should land
	# the edges of the map always have bounds, so we always stop at the edge (if we hit nothing else)
	var result = space_state.intersect_ray(from, to, data.exclude, col_layer)
	return result

func snap_to_existing_point(data, key):
	var pos = data[key]
	data[key] = {
		'point': null,
		'pos': pos,
		'already_created': false
	}
	
	var snap_point = get_closest_point(pos, data.from_edge)
	if not snap_point: return
	
	data[key] = {
		'point': snap_point,
		'pos': snap_point.position,
		'already_created': true
	}

func does_edge_already_exist(data):
	if not data.from.already_created: return false
	if not data.to.already_created: return false
	
	var starting_point = data.from.point
	var target_point = data.to.point
	
	return target_point.m.edges.get_to(starting_point)

func is_edge_too_short(data):
	if data.dont_create_new_edges: return false
	
	var dist_between_points = (data.to.pos - data.from.pos).length()
	return (dist_between_points < MIN_JUMP_DIST)

func is_shot_along_current_edge(data):
	var cur_edge = data.from_edge
	if not cur_edge: return false
	
	var edge_vec = cur_edge.m.body.get_vec()
	var dot = data.dir.dot(edge_vec.normalized())
		
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
		for edge in from_p.m.edges.get_them():
			var edge_vec = edge.m.body.get_vec_starting_from(from_p).normalized()
			var dot = edge_vec.dot(vec)
			if dot < 0.93: continue
				
			if edge.m.body.start == from_p:
				return edge.m.body.end
			return edge.m.body.start
	
	if data.to.point:
		var to_p = data.to.point
		for edge in to_p.m.edges.get_them():
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
	
	edgeA.m.boss.set_to(data_to_transfer.boss)
	edgeA.m.boss.set_to_specific_time(data_to_transfer.boss_time_left)
	
	edgeB.m.boss.set_to(data_to_transfer.boss)
	edgeB.m.boss.set_to_specific_time(data_to_transfer.boss_time_left)
	
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

func get_closest_point(pos : Vector2, from_edge = null):
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
	
	var best_point_same_edge = null
	var best_dist_same_edge = INF
	
	for res in result:
		if not res.collider.is_in_group("Points"): continue
		
		var dist = (res.collider.position - pos).length()
		if dist < best_dist:
			best_dist = dist
			best_point = res.collider
		
		if not from_edge: continue
		
		var on_same_edge = from_edge.m.body.is_part_of_me(res.collider)
		if dist < best_dist_same_edge and on_same_edge:
			best_dist_same_edge = dist
			best_point_same_edge = res.collider
	
	if best_point_same_edge:
		return best_point_same_edge

	return best_point

func get_closest_entity(pos : Vector2, exclude = []):
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = ENTITY_OBSTRUCT_RADIUS
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	query_params.collision_layer = 2 + 4
	
	var result = space_state.intersect_shape(query_params)
	if not result: return null
	
	for res in result:
		if res.collider in exclude: continue
		return res.collider
	
	return null

func remove_existing(edge, destroy_orphan_points = true, keep_entities_alive = false):
	
	# if the plan was to destroy entities
	# but there's a reason this edge must be kept alive
	var edge_must_stay_alive = edge.m.entities.has_strong_one() or edge.m.body.cant_destroy_due_to_home_base()
	if not keep_entities_alive and edge_must_stay_alive:
		return
	
	var start_node = edge.m.body.start
	var end_node = edge.m.body.end
	
	start_node.m.edges.remove(edge, destroy_orphan_points)
	
	var end_isnt_already_destroyed = is_instance_valid(end_node)
	if end_isnt_already_destroyed:
		end_node.m.edges.remove(edge, destroy_orphan_points)
	
	var type = edge.m.type.get_it()
	var boss = edge.m.boss.get_it()
	var boss_time_left = edge.m.boss.get_time_left()
	var entities = edge.m.entities.get_them()
	if not keep_entities_alive:
		for entity in entities:
			entity.m.status.die()
	
	edge.queue_free()
	
	return {
		'entities': entities,
		'type': type,
		'boss': boss,
		'boss_time_left': boss_time_left
	}

func create_between(a, b):
	var e = edge_scene.instance()
	add_child(e)
	e.m.body.set_extremes(a, b)
	e.m.drawer.play_creation_tween()
	
	a.m.edges.add(e)
	b.m.edges.add(e)
	
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
