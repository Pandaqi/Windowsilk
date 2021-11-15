extends Node2D

var point_scene = preload("res://scenes/web/point.tscn")

onready var web = get_parent()
onready var edges = get_node("../Edges")

var debug : bool = false

func create_at(pos):
	var p = point_scene.instance()
	p.set_position(pos)
	add_child(p)
	
	p.m.drawer.play_creation_tween()
	p.m.status.check()
	
	if Global.in_game:
		p.erase_module('menu')
	
	if debug:
		print("Point Created")
		print(pos)
		print()
	
	return p

func remove_existing(point):
	if point.m.status.is_home_base(): return
	if point.m.body.is_fixed(): return
	
	var entities_copy = point.m.entities.get_them() + []
	for e in entities_copy:
		e.m.status.die()
	
	var edges_copy = point.m.edges.get_them() + []
	var not_all_removed = false
	for e in edges_copy:
		var res = edges.remove_existing(e)
		if res.failed: not_all_removed = true
	
	if not_all_removed: return

	point.queue_free()

func get_random():
	var points = get_tree().get_nodes_in_group("Points")
	return points[randi() % points.size()]
