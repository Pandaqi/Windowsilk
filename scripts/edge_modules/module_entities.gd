extends Node2D

var entities = []

onready var body = get_parent()

func add(e):
	entities.append(e)

func remove(e):
	entities.erase(e)

func get_them():
	return entities

func is_on_me(e, epsilon = 5.0):
	var start_pos = body.m.body.start.position
	var end_pos = body.m.body.end.position
	
	return body.m.body.point_is_between(start_pos, end_pos, e.position, epsilon)
