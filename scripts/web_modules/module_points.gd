extends Node2D

var point_scene = preload("res://scenes/web/point.tscn")

onready var web = get_parent()
onready var edges = get_node("../Edges")

var debug : bool = true

func create_at(pos):
	var p = point_scene.instance()
	p.set_position(pos)
	web.add_child(p)
	
	if debug:
		print("Point Created")
		print(pos)
		print()
	
	return p

func remove_existing(point):
	for e in point.get_edges():
		edges.remove_existing(e)
	
	point.queue_free()