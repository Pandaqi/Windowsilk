extends Node2D

var entities = []
onready var body = get_parent()

func add(e):
	entities.append(e)
	
	body.m.homebase.check_player_entrance(e)

func remove(e):
	entities.erase(e)

func get_them():
	return entities

func update_positions():
	for e in entities:
		e.m.tracker.update_positions()
