extends Node2D

onready var body = get_parent()

var player_num : int = -1

func initialize(pnum):
	player_num = pnum
	body.m.input.set_player_num(pnum)
	body.m.webtracker.start_randomly()
