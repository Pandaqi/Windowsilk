extends Node2D

onready var players = get_node("/root/Main/Players")

func _unhandled_input(ev):
	var res = GlobalInput.check_new_player(ev)
	if not res.failed:
		players.create_new(GlobalInput.get_player_count() - 1)
	
	#GlobalInput.check_remove_player(ev)
