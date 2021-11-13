extends Node2D

var type : String = ""
var num_players_here : int = 0
var num_players_nearby : int = 0
var team_num : int = -1

var react_to_nearby_players = ["arenas", "bugs", "settings", "quit"]

onready var body = get_parent()
onready var feedback = get_node("/root/Main/Feedback")
onready var main_node = get_node("/root/Main")

func set_type(tp):
	type = tp
	
	# TO DO: change appearance?

func on_entity_enter(e):
	if type == "": return
	
	if e.is_in_group("Players"):
		num_players_here += 1
	
	check_for_action(e)

func check_for_action(e):
	if num_players_here <= 0: return
	if not e.is_in_group("Players"): return
	
	# TO DO: Custom functionalities for menu here
	if type == "start":
		pass
		
	elif type == "play":
		if num_players_here == GlobalInput.get_player_count():
			start_game()
		
	elif type == "team":
		GlobalDict.player_data[e.m.status.player_num].team = team_num
		e.m.status.change_team(team_num)
		feedback.create(body.position, "Changed team!")
		main_node.emit_signal("team_changed", e)
		
	elif type == "settings":
		main_node.emit_signal("open_settings")
		
	elif type == "bugs":
		Global.custom_web_to_load = "bugs"
		get_tree().reload_current_scene()
		
	elif type == "arenas":
		Global.custom_web_to_load = "arenas"
		get_tree().reload_current_scene()
		
	elif type == "quit":
		get_tree().quit()
	
	elif type == "exit":
		Global.custom_web_to_load = "menu"
		get_tree().reload_current_scene()

func on_entity_exit(e):
	if type == "": return
	if e.is_in_group("Players"):
		num_players_here -= 1

func start_game():
	Global.start_game()

func _on_Area2D_body_entered(other_body):
	if not other_body.is_in_group("Players"): return
	if not (type in react_to_nearby_players): return
	
	num_players_nearby += 1
	
	if num_players_nearby > 0:
		main_node.emit_signal("players_nearby", true, type)

func _on_Area2D_body_exited(other_body):
	if not other_body.is_in_group("Players"): return
	if not (type in react_to_nearby_players): return
	
	num_players_nearby -= 1
	
	if num_players_nearby <= 0:
		main_node.emit_signal("players_nearby", false, type)
