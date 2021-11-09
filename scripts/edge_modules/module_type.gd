extends Node2D

const TYPE_THRESHOLD : float = 80.0

var type : String = "regular"
var data
var category_data

var one_way_dir : int = 1

onready var body = get_parent()

func create_debug_terrain_type():
	var all_types = GlobalDict.silk_types.keys()
	set_to(all_types[randi() % all_types.size()])
	
	# DEBUGGING
	set_to('flight')

func set_to(tp):
	if too_short_for_terrain():
		tp = "regular"
	
	type = tp
	data = GlobalDict.silk_types[type]
	category_data = GlobalDict.silk_categories[data.category]
	
	body.m.drawer.set_icon(data.frame)
	body.m.drawer.set_color(category_data.color)
	
	check_one_way()
	body.m.entities.inform_all_of_type_change()

func check_one_way():
	one_way_dir = 1 if randf() <= 0.5 else -1
	
	if one_way_dir == -1:
		body.m.drawer.rotate_icon(-PI)

func disallows_breaking():
	return type == "strong"

func direction_forbidden(vec):
	if type != "oneway": return false
	
	var dot = vec.normalized().dot(body.m.body.get_vec_norm())
	if sign(dot) == sign(one_way_dir): return false
	return true

func too_short_for_terrain():
	return body.m.body.get_length() <= TYPE_THRESHOLD

func equals(tp):
	return type == tp

func get_it():
	return type

func is_special():
	return type != "regular"
