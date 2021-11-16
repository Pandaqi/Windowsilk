extends Node2D

const TIMER_BOUNDS = { 'min': 5, 'max': 10 }
onready var timer = $Timer

onready var tracker_handler = get_parent()
onready var body = tracker_handler.get_parent()

var cur_state : String = "web"
var want_to_switch : bool = false

func is_player_in_flight():
	if not body.m.status.is_player(): return false
	if cur_state != 'fly': return false
	return true

func restart_timer():
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func _on_Timer_timeout():
	want_to_switch = true

	if cur_state == "web": fly()

func switch_to(tp, params = {}):
	if body.m.status.is_incapacitated: return
	
	# first, remove us from any positions we're saved
	body.m.tracker.remove_from_all()
	
	# remember we switched (and to where)
	cur_state = tp
	want_to_switch = false
	
	# activate the correct module
	if tp == "web":
		body.m.mover.select_module("WebMover")
		body.m.movement.select_module("WebMovement")
		body.m.tracker.select_module("WebTracker")
	
	elif tp == "fly":
		body.m.mover.select_module("FlyMover")
		body.m.movement.select_module("FlyMovement")
		body.m.tracker.select_module("FlyTracker")
	
	# if it's an AI bug, restart movement calculation
	# and restart our timer for the next switch
	if not body.m.status.is_player(): 
		body.m.movement.initialize()
		
		handle_flying_bugs_that_can_land()
	else:
		body.m.movement.disable()
	
	# start the tracker again, which should place us correctly back at our old location
	body.m.tracker.initialize(params)
	
	# inform visuals of the change
	body.m.visuals.on_move_type_changed(cur_state)
	
	tracker_handler.emit_signal("on_switch")

func handle_flying_bugs_that_can_land():
	if not tracker_handler.data.has('land'): return
	
	restart_timer()
	
	if cur_state == "web":
		body.m.mover.disable()
	else:
		body.m.mover.enable()

func arrived_on_edge(e):
	try_landing(null, e)

func arrived_on_point(p):
	try_landing(p, null)

func request_flight():
	fly()

func fly():
	var params = {
		'fixed_pos': body.position,
	}
	
	switch_to("fly", params)

func land(point, edge):
	var params = {
		'fixed_pos': null,
		'fixed_point': point,
		'fixed_edge': edge 
	}
	
	switch_to("web", params)

func request_landing():
	var point = tracker_handler.get_current_point()
	var edge = tracker_handler.get_current_edge()
	
	want_to_switch = true
	try_landing(point, edge)

func try_landing(point, edge):
	if not want_to_switch: return
	
	var nowhere_to_land = (not point) and (not edge)
	if nowhere_to_land:
		body.m.status.give_feedback("Nowhere to land!")
		body.m.status.die()
		return
	
	land(point, edge)

