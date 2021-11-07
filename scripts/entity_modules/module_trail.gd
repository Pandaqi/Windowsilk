extends Node2D

var type : String = ""
var last_known_edge = null

var painting_allowed : bool = true
onready var timer = $Timer
onready var body = get_parent()

func set_to(tp):
	if not tp: return
	type = tp

func die():
	type = ""
	last_known_edge = null

func _on_Tracker_arrived_on_edge(e):
	last_known_edge = e
	
	var switched_to_new_edge = last_known_edge and (e != last_known_edge)
	if switched_to_new_edge and GlobalDict.cfg.paint_trails_when_jumping:
		paint()

func _on_Tracker_arrived_on_point(_p):
	paint()

func paint_specific_edge(e):
	last_known_edge = e
	paint()

func paint():
	if not last_known_edge or not is_instance_valid(last_known_edge): return
	if not painting_allowed: return
	
	var temp_type = type
	if body.m.specialties.erase_silk_types():
		temp_type = "regular"
	if temp_type == "": return
	
	last_known_edge.m.type.set_to(temp_type)
	
	disable_painting()

func disable_painting():
	painting_allowed = false
	timer.start()

func _on_Timer_timeout():
	painting_allowed = true
