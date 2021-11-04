extends Node2D

var point_scene = preload("res://scenes/web/point.tscn")

onready var web = get_parent()
onready var edges = get_node("../Edges")

var debug : bool = false

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
	var edges_copy = point.get_edges() + []
	for e in edges_copy:
		var data_to_transfer = edges.remove_existing(e)
		
		for entity in data_to_transfer.entities:
			entity.m.status.die()
	
	point.queue_free()

func get_random():
	var points = get_tree().get_nodes_in_group("Points")
	return points[randi() % points.size()]
