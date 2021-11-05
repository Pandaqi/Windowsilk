extends "res://scripts/module_selector.gd"

const BASE_SPEED : float = 50.0
var speed : float = BASE_SPEED
var is_static : float = false

signal on_move_completed(vec)

func _on_Movement_move_vec(vec, dt):
	if not active: return
	if is_static: return
	
	var not_moving = (vec.length() <= 0.03)
	if not_moving: return
	
	var cur_pos = body.position
	active_module._on_Input_move_vec(vec, dt)
	
	var new_pos = body.position
	emit_signal("on_move_completed", (new_pos - cur_pos))

func _on_Tracker_arrived_on_edge(e):
	if not active_module.has_method("_on_Tracker_arrived_on_edge"): return
	active_module._on_Tracker_arrived_on_edge(e)

func _on_Tracker_arrived_on_point(p):
	if not active_module.has_method("_on_Tracker_arrived_on_point"): return
	active_module._on_Tracker_arrived_on_point(p)

func try_edge_move(vec, dt):
	if not active_module.has_method("try_edge_move"): return
	active_module.try_edge_move(vec, dt)

func set_speed(sp):
	speed = sp

func make_static():
	is_static = true





