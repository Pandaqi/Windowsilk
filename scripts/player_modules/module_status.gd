extends Node2D

onready var body = get_parent()
onready var main_node = get_node("/root/Main")

var player_num : int = -1
var team_num : int = -1
var is_dead : bool = false

func initialize(pnum, tnum):
	player_num = pnum
	team_num = tnum
	
	body.m.input.set_player_num(pnum)
	body.m.webtracker.start_randomly({ 'avoid_players': true })

func die():
	is_dead = true
	body.m.webtracker.die()
	main_node.on_player_death(body)
	
	body.modulate.a = 0.3
	
	# TO DO: more here of course
