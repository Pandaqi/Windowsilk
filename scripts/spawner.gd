extends Node2D

const OFFSET_FROM_EDGE : Dictionary = { 'min': 50.0, 'max': 150.0 }
const DEFAULT_SPAWN_CHECK_RADIUS : float = 50.0

onready var players = get_node("../Players")

func get_random_position(params = {}):
	var data = {
		'pos': Vector2.ZERO,
		'edge': null
	}
	
	var edges = get_tree().get_nodes_in_group("Edges")
	var rand_edge = edges[randi() % edges.size()]
	data.edge = rand_edge
	
	var vec = rand_edge.m.body.get_vec()
	var vec_norm = vec.normalized()
	var rand_pos = rand_edge.m.body.start.position + randf()*vec
	data.pos = rand_pos
	
	if not params.has('avoid_web') or not params.avoid_web: return data
	
	var ortho_vec = vec_norm.rotated(0.5*PI)
	if randf() <= 0.5: ortho_vec = vec_norm.rotated(-0.5*PI)
	
	rand_pos += ortho_vec*rand_range(OFFSET_FROM_EDGE.min, OFFSET_FROM_EDGE.max)
	data.pos = rand_pos
	
	return data

func get_valid_random_position(params = {}):
	var bad_pos = true
	var pos
	
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

func get_intersections(pos : Vector2, radius : float = 10.0):
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = radius
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	
	var result = space_state.intersect_shape(query_params)
	return result
