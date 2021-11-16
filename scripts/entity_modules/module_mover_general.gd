extends "res://scripts/module_selector.gd"

const BASE_SPEED : float = 50.0
var speed : float = BASE_SPEED

const SPEED_SCALE_BOUNDS = { 'min': 0.5, 'max': 1.5 }
const SPEED_LOSS_PER_POINT = 0.05

var speed_scale : float = 1.0
var is_static : float = false

# warning-ignore:unused_signal
signal on_move_stopped()
signal on_move_completed(vec)

func _on_Movement_move_vec(vec, dt):
	if not active: return
	if is_static: 
		active_module.stop()
		return

	var not_moving = (vec.length() <= 0.03)
	if not_moving: 
		active_module.stop()
		return

	active_module._on_Input_move_vec(vec, dt)

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

func get_final_speed():
	return speed * speed_scale

func force_update_speed_scale(val):
	speed_scale = val

func update_speed_scale(num):
	if not GlobalDict.cfg.bigger_entities_move_slower: return
	if not Global.in_game: return
	
	speed_scale = max(SPEED_SCALE_BOUNDS.max - SPEED_LOSS_PER_POINT*num, SPEED_SCALE_BOUNDS.min)

func make_static():
	is_static = true
