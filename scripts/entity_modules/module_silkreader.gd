extends Node2D

const SLIPPERY_FACTOR : float = 0.1 # lower = more slippery
const FEATHERLIGHT_SPEED : float = 0.1 # how fast points move inwards

var cur_edge = null
var cur_silk_type = null

onready var body = get_parent()

func reset_silk_type():
	cur_silk_type = null
	cur_edge = null

func update_silk_type(edge):
	cur_edge = edge
	cur_silk_type = edge.m.type.get_it()

func _physics_process(dt):
	handle_continuous_effects(dt)

func handle_continuous_effects(dt):
	if not cur_silk_type: return
	
	# NOTE: if we immediately start changing points, we might get stuck on the starting point (as it just moved underneath us), so only start slightly later, works wonders
	var far_enough_on_edge = cur_edge.m.body.get_dist_to_closest_point(body) > 20
	if cur_silk_type == "featherlight" and far_enough_on_edge:
		cur_edge.m.body.move_extremes_inward(FEATHERLIGHT_SPEED, dt)

func handle_rotation(cur_rot, target_rot, input_vec):
	if cur_silk_type != "slippery": return target_rot
	
	var cur_vec = Vector2(cos(cur_rot), sin(cur_rot))
	var target_vec = input_vec
	
	var slerped_vec = cur_vec.slerp(target_vec, SLIPPERY_FACTOR)
	return slerped_vec.angle()

func modify_input_vec(vec):
	if cur_silk_type != "slippery": return vec
	
	var cur_rot = body.rotation
	var cur_vec = Vector2(cos(cur_rot), sin(cur_rot))
	return cur_vec.slerp(vec, SLIPPERY_FACTOR)

func modify_speed(new_vec, new_speed):
	if cur_silk_type == "speedy": new_speed *= 1.5
	elif cur_silk_type == "slowy": new_speed *= 0.5

	return new_vec * new_speed

func modify_points(val):
	if cur_silk_type == "doubler": val *= 2
	elif cur_silk_type == "worthless": val = 0
	return val

func jumping_is_free():
	return cur_silk_type == "trampoline"

func jumping_is_forbidden():
	return cur_silk_type == "sticky"

func jumping_is_aggressive():
	return cur_silk_type == "aggressor"

func _on_Tracker_arrived_on_edge(e):
	update_silk_type(e)

func _on_Tracker_arrived_on_point(p):
	reset_silk_type()
