extends Node2D

var cur_edge = null
var cur_silk_type = null
var active : bool = true

onready var body = get_parent()

const STUCK_CHECK_INTERVAL : float = 3.0
onready var stuck_timer = $StuckTimer

func disable():
	active = false
	stuck_timer.stop()

func enable():
	active = true
	
	stuck_timer.wait_time = STUCK_CHECK_INTERVAL
	stuck_timer.start()

func reset_silk_type():
	cur_silk_type = null
	cur_edge = null

func update_silk_type(edge):
	cur_edge = edge
	cur_silk_type = edge.m.type.get_it()

func _on_Tracker_arrived_on_edge(e):
	update_silk_type(e)

func _on_Tracker_arrived_on_point(_p):
	reset_silk_type()

func _on_Status_on_death():
	disable()
	reset_silk_type()

func _on_Respawner_on_revive():
	enable()

func check_if_were_stuck(edge = null):
	if not edge: edge = cur_edge
	
	if not edge or not is_instance_valid(edge): return
	if not edge.m.boss.has_one(): return
	if edge.m.boss.is_safe_for(body): return
	
	var prob = 1.0 - body.m.points.count() / (GlobalDict.cfg.max_points_capacity + 1.0)
	if randf() > prob: return

	position_precisely_on_edge(edge)

	body.m.status.incapacitate()

func _on_StuckTimer_timeout():
	check_if_were_stuck()

func position_precisely_on_edge(e):
	var closest_point = e.m.body.get_closest_point(body)
	var dist_to_closest_point = (body.position - closest_point.position).length()
	
	var vec = e.m.body.get_vec_starting_from(closest_point)
	var approximate_pos = closest_point.position + vec.normalized() * dist_to_closest_point
	
	var movement_needed = (approximate_pos - body.position)
	body.move_and_collide(movement_needed)
