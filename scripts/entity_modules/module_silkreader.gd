extends Node2D

const FEATHERLIGHT_SPEED : float = 0.1 # how fast points move inwards

var cur_edge = null
var cur_silk_type = null
var active : bool = true

onready var body = get_parent()

func disable():
	active = false

func reset_silk_type():
	cur_silk_type = null
	cur_edge = null

func update_silk_type(edge):
	cur_edge = edge
	cur_silk_type = edge.m.type.get_it()

func _physics_process(dt):
	if not active: return
	handle_continuous_effects(dt)

func handle_continuous_effects(dt):
	if not cur_silk_type: return
	
	# NOTE: if we immediately start changing points, we might get stuck on the starting point (as it just moved underneath us), so only start slightly later, works wonders
	var far_enough_on_edge = cur_edge.m.body.get_dist_to_closest_point(body) > 20
	if cur_silk_type == "featherlight" and far_enough_on_edge:
		cur_edge.m.body.move_extremes_inward(FEATHERLIGHT_SPEED, dt)

func _on_Tracker_arrived_on_edge(e):
	update_silk_type(e)

func _on_Tracker_arrived_on_point(p):
	reset_silk_type()

func _on_Status_on_death():
	disable()
	reset_silk_type()
