extends "res://scripts/module_selector.gd"

const BASE_SPEED : float = 50.0
var speed : float = BASE_SPEED

func _on_Movement_move_vec(vec, dt):
	if not active: return
	
	var not_moving = (vec.length() <= 0.03)
	if not_moving: return
	
	active_module._on_Input_move_vec(vec, dt)

func _on_Tracker_arrived_on_edge(e):
	if not active_module.has_method("_on_Tracker_arrived_on_edge"): return
	active_module._on_Tracker_arrived_on_edge(e)

func _on_Tracker_arrived_on_point(p):
	if not active_module.has_method("_on_Tracker_arrived_on_point"): return
	active_module._on_Tracker_arrived_on_point(p)

func set_speed(sp):
	speed = sp






