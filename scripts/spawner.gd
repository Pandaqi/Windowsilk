extends Node2D

const BOUNDS = { 'min': 3, 'max': 8 }
const TIME_BOUNDS = { 'min': 3.0, 'max': 7.0 }

const OFFSET_FROM_EDGE : Dictionary = { 'min': 50.0, 'max': 150.0 }
const DEFAULT_SPAWN_CHECK_RADIUS : float = 50.0

var item_scene = preload("res://scenes/item.tscn")

var available_types = ['silk']
var place_on_web : bool = true

onready var players = get_node("../Players")

onready var timer = $Timer

var placement_params = {
	'small_radius': 30.0,
	'large_radius': 250.0,
	'avoid_items': true,
	'avoid_players': true,
	'avoid_web': false
}

func activate():
	_on_Timer_timeout()

func _on_Timer_timeout():
	check_placement()
	restart_timer()

func restart_timer():
	timer.wait_time = rand_range(TIME_BOUNDS.min, TIME_BOUNDS.max)
	timer.start()

func check_placement():
	var num_items = get_tree().get_nodes_in_group("Items").size()
	if num_items >= BOUNDS.max: return
	
	place_item()
	num_items += 1
	
	while num_items < BOUNDS.min:
		place_item()
		num_items += 1

func get_random_type():
	return available_types[randi() % available_types.size()]

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
	if placement_params.has('small_radius'): small_radius = placement_params.small_radius
	if placement_params.has('large_radius'): large_radius = placement_params.large_radius
	
	var avoid_players = params.has('avoid_players')
	var avoid_web = params.has('avoid_web')
	var avoid_items = params.has('avoid_items')
	
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
			if avoid_web and num_tries < 200:
				if res.collider.is_in_group("Edges"):
					bad_pos = true
					break
			
			if avoid_items and num_tries < 300:
				if res.collider.is_in_group("ItemBodies"):
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

func place_item():
	var item = item_scene.instance()
	
	placement_params.avoid_web = should_create_item_off_web()
	
	var spawn_data = get_valid_random_position(placement_params)
	
	item.set_position(spawn_data.pos)
	item.set_type(get_random_type())
	item.set_on_web(not placement_params.avoid_web)
	add_child(item)

func should_create_item_off_web():
	var items = get_tree().get_nodes_in_group("Items")
	var count = {
		'on_web': 0,
		'off_web': 0
	}
	
	for item in items:
		if item.on_web: count.on_web += 1
		else: count.off_web += 1
	
	return (count.off_web < count.on_web)
