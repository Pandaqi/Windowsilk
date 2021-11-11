extends Node2D

onready var body = get_parent()

func check():
	body.m.body.update_body()
	body.m.drawer.update_visuals()
	body.m.entities.update_positions()
	body.m.edges.update_edges()

func convert_to_home_base(num):
	body.m.homebase.activate(num)

func is_home_base():
	return body.m.homebase.active

func build_exclude_array():
	var exclude = [body]
	exclude += body.m.edges.get_them()
	return exclude
