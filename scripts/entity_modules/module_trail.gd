extends Node2D

var type : String = ""
var last_known_edge = null

var painting_allowed : bool = true
onready var timer = $Timer

func set_to(tp):
	if not tp: return
	type = tp

func die():
	type = ""
	last_known_edge = null

func _on_Tracker_arrived_on_edge(e):
	last_known_edge = e

func _on_Tracker_arrived_on_point(p):
	paint()

func paint_specific_edge(e):
	last_known_edge = e
	paint()

func paint():
	if type == "": return
	if not painting_allowed: return
	if not last_known_edge: return
	
	last_known_edge.m.type.set_to(type)
	
	disable_painting()

func disable_painting():
	painting_allowed = false
	timer.start()

func _on_Timer_timeout():
	painting_allowed = true
