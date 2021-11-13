extends Node2D

var type : String = ""
var num_players_here : int = 0

func on_entity_enter(e):
	if type == "": return
	
	if e.is_in_group("Players"):
		num_players_here += 1
	
	if num_players_here <= 0: return
	
	# TO DO: Custom functionalities for menu here
	if type == "start":
		if num_players_here == GlobalInput.get_player_count():
			start_game()
	elif type == "team":
		pass
	elif type == "settings":
		pass
	elif type == "bugs":
		pass
	elif type == "arenas":
		pass

func on_entity_exit(e):
	if type == "": return
	if e.is_in_group("Players"):
		num_players_here -= 1

func start_game():
	pass
