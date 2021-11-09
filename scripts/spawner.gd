extends Node2D

const OFFSET_FROM_EDGE : Dictionary = { 'min': 50.0, 'max': 150.0 }
const DEFAULT_SPAWN_CHECK_RADIUS : float = 50.0

onready var players = get_node("../Players")

func get_random_position(params = {}):
	if params.has('nearby_point'):
		var center_pos = params.nearby_point.position
		var rad = params.nearby_radius
		
		var edges = get_intersections(center_pos, rad, true)
		if edges.size() <= 0:
			return {
				'pos': center_pos,
				'edge': null
			}
		
		var rand_edge = edges[randi() % edges.size()]
		var vec = rand_edge.m.body.get_vec_starting_from(params.nearby_point)
		
		var progression_on_edge = 0.5+randf()*0.5
		var pos = center_pos + progression_on_edge*rad*vec.normalized()
		
		return {
			'pos': pos,
			'edge': rand_edge
		}
	
	var data = {
		'pos': Vector2.ZERO,
		'edge': null
	}
	
	var edges = get_tree().get_nodes_in_group("Edges")
	var rand_edge = edges[randi() % edges.size()]
	data.edge = rand_edge
	data.pos = rand_edge.m.body.get_random_pos_on_me(0.2)
	
	if not params.has('avoid_web') or not params.avoid_web: return data
	
	var vec_norm = rand_edge.m.body.get_vec_norm()
	var ortho_vec = vec_norm.rotated(0.5*PI)
	if randf() <= 0.5: ortho_vec = vec_norm.rotated(-0.5*PI)
	
	data.pos += ortho_vec*rand_range(OFFSET_FROM_EDGE.min, OFFSET_FROM_EDGE.max)
	
	return data

func get_valid_random_position(params = {}):
	var bad_pos = true

	var small_radius = DEFAULT_SPAWN_CHECK_RADIUS
	var large_radius = small_radius * 4
	if params.has('small_radius'): small_radius = params.small_radius
	if params.has('large_radius'): large_radius = params.large_radius
	
	var avoid_players = params.has('avoid_players')
	var avoid_web = params.has('avoid_web')
	var avoid_entities = params.has('avoid_entities')
	
	var avoid_bounds = true
	if params.has('avoid_bounds'): avoid_bounds = params.avoid_bounds
	
	var num_tries = 0
	var max_tries = 500
	
	# TO DO: Very repetitive code => streamline and optimize
	var data
	while bad_pos and num_tries < max_tries:
		bad_pos = false
		data = get_random_position(params)
		
		num_tries += 1
		
		var small_result = get_intersections(data.pos, small_radius)
		for res in small_result:
			if avoid_bounds:
				if res.collider.is_in_group("Bounds"):
					bad_pos = true
					break
			
			if avoid_web and num_tries < 200:
				if res.collider.is_in_group("Edges"):
					bad_pos = true
					break
			
			if avoid_entities and num_tries < 300:
				if res.collider.is_in_group("Entities"):
					bad_pos = true
					break
		
		if avoid_players:
			var closest_dist = players.get_closest_dist(data.pos)
			if closest_dist < large_radius:
				bad_pos = true
				continue

	return data

func get_intersections(pos : Vector2, radius : float = 10.0, only_edges : bool = false):
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = radius
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	
	var result = space_state.intersect_shape(query_params)
	
	if only_edges:
		var edges = []
		for res in result:
			if res.collider.is_in_group("Edges"):
				edges.append(res.collider)
		
		return edges
	
	return result
