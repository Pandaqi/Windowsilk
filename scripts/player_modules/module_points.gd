extends Node2D

var num : int = 0

onready var main_node = get_node("/root/Main")
onready var body = get_parent()

func count():
	return num

func collect(val : int):
	num = clamp(num + val, 0, 99)
	
	if not body.m.status.is_player(): return
	main_node.on_player_progression(body)
