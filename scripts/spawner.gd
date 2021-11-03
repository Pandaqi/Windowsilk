extends Node2D

const BOUNDS = { 'min': 3, 'max': 8 }
const TIME_BOUNDS = { 'min': 3.0, 'max': 7.0 }

const OFFSET_FROM_EDGE : Dictionary = { 'min': 50.0, 'max': 150.0 }
const DEFAULT_SPAWN_CHECK_RADIUS : float = 100.0

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

func get_random_position():
	var edges = get_tree().get_nodes_in_group("Edges")
	var rand_edge = edges[randi() % edges.size()]
	
	var vec = rand_edge.get_vec()
	var vec_norm = vec.normalized()
	var rand_pos = rand_edge.start.position + randf()*vec
	
	if place_on_web: return rand_pos
	
	var ortho_vec = vec_norm.rotated(0.5*PI)
	if randf() <= 0.5: ortho_vec = vec_norm.rotated(-0.5*PI)
	
	rand_pos += ortho_vec*rand_range(OFFSET_FROM_EDGE.min, OFFSET_FROM_EDGE.max)
	return rand_pos

func get_valid_random_position(params):
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
	# TO DO: Also, it's not really necessary to do an expensive intersection for the large radius => just loop through all players and check their distance
	while bad_pos and num_tries < max_tries:
		bad_pos = false
		pos = get_random_position()
		
		num_tries += 1
		
		var small_result = get_intersections(pos, small_radius)
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
			var closest_dist = players.get_closest_dist(pos)
			if closest_dist < large_radius:
				bad_pos = true
				break

	return pos

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
	
	placement_params.avoid_web = not place_on_web
	
	item.set_position(get_valid_random_position(placement_params))
	item.set_type(get_random_type())
	add_child(item)
	
	place_on_web = not place_on_web
	
	print("ITEM PLACED")
	print(item.position)
