extends Node2D

onready var body = get_parent()

var player_num : int = -1
var team_num : int = -1
var is_dead : bool = false

var type : String = ""
var data

signal on_death()

func make_player(pnum, tnum):
	player_num = pnum
	team_num = tnum
	
	body.m.input.set_player_num(pnum)
	body.m.points.set_to(GlobalDict.cfg.player_starting_points)
	body.add_to_group("Players")

func make_non_player():
	body.erase_module("input")

func is_player():
	return (player_num >= 0)

func initialize(placement_params):
	var move_type = get_move_type()
	set_move_type(move_type)
	
	if not is_player(): 
		body.m.movement.initialize()
	else:
		body.m.movement.disable()
	body.m.tracker.initialize(placement_params)

func set_move_type(tp):
	if tp == "web":
		body.m.mover.select_module("WebMover")
		body.m.movement.select_module("WebMovement")
		body.m.tracker.select_module("WebTracker")
	
	else:
		body.m.mover.select_module("FlyMover")
		body.m.movement.select_module("FlyMovement")
		body.m.tracker.select_module("FlyTracker")
	
	body.m.visuals.set_move_type(tp)

func get_move_type():
	if not data.move.has('type'): return 'web'
	return data.move.type

func set_type(tp):
	type = tp
	
	data = GlobalDict.entities[type]
	
	if data.move.has('speed'): body.m.mover.set_speed(data.move.speed)
	
	body.m.visuals.set_sprite(data.frame)
	body.m.trail.set_to(data.trail)
	body.m.points.set_to(data.points)
	body.m.movement.set_data(data)

func die():
	is_dead = true
	
	emit_signal("on_death")
	
	if is_player():
		body.modulate.a = 0.3
	else:
		body.queue_free()
