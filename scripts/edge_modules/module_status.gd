extends Node2D

onready var body = get_parent()

func check():
	body.m.body.update_body()
	body.m.drawer.update_visuals()
	body.m.entities.update_positions()
