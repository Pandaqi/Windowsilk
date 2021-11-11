extends Node2D

onready var edges = $Edges
onready var points = $Points

onready var main_node = get_node("/root/Main")

const EDGE_MARGIN : float = 50.0
const BOUND_THICKNESS : float = 64.0

var vp = Vector2(1920, 1080)
var corners = [
	Vector2.ZERO,
	Vector2(1920, 0),
	Vector2(1920, 1080),
	Vector2(0, 1080)
]

var home_bases = []

func activate():
	inset_corners()
	position_bounds()
	
	yield(get_tree(), "idle_frame")
	
	generate_random_web()

func inset_corners():
	corners[0] += Vector2(1,1)*EDGE_MARGIN
	corners[1] += Vector2(-1,1)*EDGE_MARGIN
	corners[2] += Vector2(-1,-1)*EDGE_MARGIN
	corners[3] += Vector2(1,-1)*EDGE_MARGIN

func position_bounds():
	$Bounds/Right.position.x = corners[1].x + BOUND_THICKNESS
	$Bounds/Down.position.y = corners[2].y + BOUND_THICKNESS
	$Bounds/Left.position.x = corners[0].x - BOUND_THICKNESS
	$Bounds/Up.position.y = corners[0].y - BOUND_THICKNESS

func get_random_inner_pos(params):
	var margin = Vector2.ZERO
	if params.has('margin'): Vector2(1,1)*params.margin
	
	var start = corners[0] + margin
	var width = (corners[2]-corners[0]-2*margin)
	
	if params.has('quadrant'):
		var q = params.quadrant
		width *= 0.5
		
		if q == 1:
			start = Vector2(0.5*vp.x, 0)
		elif q == 2:
			start = Vector2(0, 0.5*vp.y)
		elif q == 3:
			start = 0.5*vp
	
	return start + width*Vector2(randf(), randf())

func is_out_of_bounds(pos, margin = 0):
	return pos.x < (corners[0].x - margin) or pos.y < (corners[0].y - margin) or pos.x >= (corners[2].x + margin) or pos.y >= (corners[2].y + margin)

func get_random_vector():
	var num_angles = 16
	var rand_angle = randf()*2*PI
	var snap_angle = round(rand_angle / (2*PI) * num_angles) / num_angles * (2*PI)
	return Vector2(cos(snap_angle), sin(snap_angle))

func generate_random_web():
	#var start_pos = get_random_inner_pos(params)
	#points.create_at(start_pos)
	
	var num_debug_frames = 1
	var total_edge_length : float = 0.0
	var target_total_edge_length : float = 5000.0
	var exclude = []
	var edge
	
	var start_pos
	var counter = 0
	while total_edge_length < target_total_edge_length:
		
		var pick_randomly_from_existing = counter >= 4
		var pick_randomly_from_quadrants = counter < 4
		
		var dir = get_random_vector()
		
		if pick_randomly_from_quadrants:
			start_pos = get_random_inner_pos({ 'margin': 200, 'quadrant': counter })
		
		elif pick_randomly_from_existing:
			edge = edges.get_random()
			start_pos = edge.m.body.get_random_pos_on_me()
			exclude = [edge]
		
		var params = {
			'from': start_pos, 
			'dir': dir,
			'exclude': exclude, 
			'origin_edge': edge
		}
		
		var res = edges.shoot(params)
		
		var nothing_happened = not res.created_something
		if nothing_happened: continue
		
		var from_point_created = res.from.point
		var create_home_base = (counter < GlobalInput.get_player_count())
		if create_home_base:
			home_bases.append(from_point_created)
		
		total_edge_length += res.new_edge.m.body.get_length()
		counter += 1
		
		for _j in range(num_debug_frames):
			yield(get_tree(), "idle_frame")
	
	var min_edges = GlobalDict.cfg.min_edges_on_home_base
	var num_tries = 0
	var max_tries = 400
	
	for i in range(home_bases.size()):
		var b = home_bases[i]
		var from_pos = b.position
		
		while b.m.edges.count() < min_edges:
			var params = {
				'from': from_pos, 
				'dir': get_random_vector(),
				'exclude': b.m.status.build_exclude_array(), 
			}
			
			var res = edges.shoot(params)
			
			num_tries += 1
			if num_tries > max_tries:
				num_tries = 0
				break
			
			var nothing_happened = not res.created_something
			if nothing_happened: continue
			
			yield(get_tree(), "idle_frame")
	
	main_node.web_loading_done()

func assign_home_bases():
	var counter = 0
	for b in home_bases:
		b.m.status.convert_to_home_base(counter)
		counter += 1

func load_default_web():
	edges.shoot(corners[0], corners[2] - corners[0])

	yield(get_tree(), "idle_frame")
	
	edges.shoot(corners[1], corners[3] - corners[1])
	
	yield(get_tree(), "idle_frame")
	
	edges.shoot(0.5*vp, corners[3] - corners[1])
	
	main_node.web_loading_done()
