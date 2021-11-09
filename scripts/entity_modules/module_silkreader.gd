extends Node2D

var cur_edge = null
var cur_silk_type = null
var active : bool = true

onready var body = get_parent()

func disable():
	active = false

func enable():
	active = true

func reset_silk_type():
	cur_silk_type = null
	cur_edge = null

func update_silk_type(edge):
	cur_edge = edge
	cur_silk_type = edge.m.type.get_it()

func _on_Tracker_arrived_on_edge(e):
	update_silk_type(e)

func _on_Tracker_arrived_on_point(p):
	reset_silk_type()

func _on_Status_on_death():
	disable()
	reset_silk_type()

func _on_Respawner_on_revive():
	enable()
