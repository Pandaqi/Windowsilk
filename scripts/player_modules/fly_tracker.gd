extends Node2D

onready var spawner = get_node("/root/Main/Spawner")

onready var tracker_handler = get_parent()
onready var body = tracker_handler.get_parent()

func initialize(params):
	params.avoid_web = true
	
	var data = spawner.get_valid_random_position(params)
	var pos = data.pos
	
	if params.has('fixed_pos'):
		pos = params.fixed_pos
	
	body.set_position(pos)
