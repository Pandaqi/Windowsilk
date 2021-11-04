extends Node2D

var type : String = ""
var last_known_edge = null

func set_to(tp):
	if not tp: return
	type = tp

func die():
	type = ""
	last_known_edge = null

func _on_WebTracker_arrived_on_edge(e):
	last_known_edge = e

func _on_WebTracker_arrived_on_point(p):
	paint()

func paint():
	if type == "": return
	if not last_known_edge: return
	
	last_known_edge.m.type.set_to(type)
