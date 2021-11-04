extends Node2D

onready var body = get_parent()

var type : String = ""
var data

signal on_death()

func initialize(placement_params):
	var move_type = get_move_type()
	
	if move_type == "web":
		body.m.webtracker.start_randomly(placement_params)
		body.m.webmovement.pick_new_vec()
	else:
		body.m.flymovement.start_randomly(placement_params)

func get_move_type():
	if not data.move.has('type'): return 'web'
	return data.move.type

func set_type(tp):
	type = tp
	
	data = GlobalDict.entities[type]
	
	if data.move.has('speed'):
		body.m.webmover.set_speed(data.move.speed)
		body.m.flymover.set_speed(data.move.speed)
	
	body.m.visuals.set_sprite(data.frame)
	body.m.trail.set_to(data.trail)
	body.m.points.set_to(data.points)
	
	var move_type = get_move_type()
	if move_type == "web":
		body.erase_module("flymovement")
		body.erase_module("flymover")
	else:
		body.erase_module("webmovement")
		body.erase_module("webtracker")
		body.erase_module("webmover")
		body.erase_module("legs")

func die():
	emit_signal("on_death")
	body.queue_free()
