extends Node2D

onready var spawner = get_node("/root/Main/Spawner")

onready var tracker_handler = get_parent()
onready var body = tracker_handler.get_parent()

func initialize(params):
	params.avoid_web = true
	
	var data = spawner.get_valid_random_position(params)
	
	body.set_position(data.pos)

func die():
	pass
