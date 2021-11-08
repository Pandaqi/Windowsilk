extends Node2D

onready var body = get_parent()
onready var main_node = get_node("/root/Main")

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
	body.m.visuals.set_player_num(pnum)
	body.add_to_group("Players")

func make_non_player():
	body.erase_module("input")
	
	body.add_to_group("NonPlayers")

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
	
	elif tp == "fly":
		body.m.mover.select_module("FlyMover")
		body.m.movement.select_module("FlyMovement")
		body.m.tracker.select_module("FlyTracker")

func get_move_type():
	if not data.has('move'): return 'web'
	if not data.move.has('type'): return 'web'
	return data.move.type


func set_type(tp):
	type = tp
	
	data = GlobalDict.entities[type]

	if not data.has('move'): data.move = {}
	if not data.has('collect'): data.collect = {}
	
	if data.move.has('speed'): body.m.mover.set_speed(data.move.speed)
	if data.move.has('static'): body.m.mover.make_static()
	
	if data.has('trail'): body.m.trail.set_to(data.trail)
	
	body.m.visuals.set_data(data)
	body.m.points.set_to(data.points)
	
	body.m.collector.set_data(data)
	body.m.movement.set_data(data)
	
	if data.has('specialty'):
		body.m.specialties.set_to(data.specialty)

func same_type_as_node(node):
	var other_type = node.m.status.type
	return (type == other_type)

func same_type(tp):
	return type == tp

# For catching/trapping bugs => we don't want to KILL them, as they'd just disappear from the map then => killing happens when a player stumbles upon them and eats
func incapacitate():
	body.m.movement.disable()
	body.m.mover.disable()

func die():
	if is_dead: return
	
	is_dead = true

	emit_signal("on_death")
	
	if is_player():
		body.modulate.a = 0.3
		main_node.on_player_death(body)
	else:
		body.queue_free()
