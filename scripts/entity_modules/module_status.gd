extends Node2D

onready var body = get_parent()
onready var main_node = get_node("/root/Main")

var player_num : int = -1
var team_num : int = -1
var is_dead : bool = false
var is_incapacitated : bool = false

var type : String = ""
var data

signal on_death()

# DEBUGGING (insta-death)
#func _input(ev):
#	if ev.is_action_released("ui_up") and player_num == 0:
#		die()

func make_player(pnum, tnum):
	player_num = pnum
	team_num = tnum
	
	body.m.input.set_player_num(pnum)
	body.m.points.set_to(GlobalDict.cfg.player_starting_points)
	body.m.visuals.set_player_num(pnum)
	body.add_to_group("Players")
	
	body.m.movement.shutdown()

func make_non_player():
	body.erase_module("input")
	body.add_to_group("NonPlayers")

func is_player():
	return (player_num >= 0)

func initialize(placement_params):
	body.m.tracker.set_move_type(get_move_type(), placement_params)

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
	
	body.m.tracker.set_data(data.move)
	
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
	is_incapacitated = true
	
	body.m.movement.disable()
	body.m.mover.disable()
	body.m.visuals.incapacitate()

func die():
	if is_dead: return
	is_dead = true

	emit_signal("on_death")
	
	if not is_player():
		body.m.tracker._on_Status_on_death() # we call this manually as it only needs to be called for non-players
		body.queue_free()
		return
	
	var should_respawn = GlobalDict.cfg.respawn_on_death
	if not should_respawn:
		main_node.on_player_death(body)
	else:
		body.m.respawner.start_respawn()

func _on_Respawner_on_revive():
	is_dead = false
