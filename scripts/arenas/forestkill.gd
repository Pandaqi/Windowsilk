extends Node2D

var points = {}

onready var web = get_node("/root/Main/Web")

func prepare_entity_placement():
	var types = GlobalDict.cfg.bugs
	var num_points_to_fix = types.size()
	
	var all_points = get_tree().get_nodes_in_group("Points")
	for i in range(all_points.size()-1,-1,-1):
		var p = all_points[i]
		if p.m.status.is_home_base():
			all_points.remove(i)
		
		if web.is_point_on_level_bound(p):
			all_points.remove(i)
	
	all_points.shuffle()
	
	# in case we have fewer points than bugs to distribute
	# some points will just do double duty
	for i in range(num_points_to_fix):
		var point = all_points[i % int(all_points.size())]
		fix_point(types[i], point)

func fix_point(type, point):
	points[type] = point
	point.m.body.make_fixed()

func hijack_entity_placement(body):
	var type = body.m.status.type
	if not points.has(type): return null
	return points[type]
