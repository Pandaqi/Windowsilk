extends Node2D

onready var spawner = get_node("/root/Main/Spawner")

onready var tracker_handler = get_parent()
onready var body = tracker_handler.get_parent()

onready var area = $Area2D

var cur_edge
var cur_point

func initialize(params):
	params.avoid_web = true
	
	var data = spawner.get_valid_random_position(params)
	var pos = data.pos
	
	if params.has('fixed_pos'):
		pos = params.fixed_pos
	
	body.set_position(pos)

func get_current_edge():
	return cur_edge

func get_current_point():
	return cur_point

func arrived_on_edge(e):
	cur_edge = e
	tracker_handler.switcher.arrived_on_edge(e)

func arrived_on_point(p):
	cur_point = p
	tracker_handler.switcher.arrived_on_point(p)

func _on_Area2D_body_entered(other_body):
	if other_body.is_in_group("Edges"):
		arrived_on_edge(other_body)
	elif other_body.is_in_group("Points"):
		arrived_on_point(other_body)

func _on_Area2D_body_exited(other_body):
	if other_body == cur_edge:
		cur_edge = null
	elif other_body == cur_point:
		cur_point = null
