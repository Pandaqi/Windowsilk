extends Node2D

onready var web = $Web
onready var spawner = $Spawner
onready var players = $Players

func _ready():
	randomize()
	
	if GlobalInput.get_player_count() <= 0:
		GlobalInput.create_debugging_players()
	
	web.activate()

func web_loading_done():
	players.activate()
	spawner.activate()

func on_player_death(p):
	print("PLAYER DIED")
	
	var teams_left = players.get_teams_left()
	if teams_left.size() > 1: return
	
	game_over(teams_left[0])

func on_player_progression(p):
	print("PLAYER PROGRESSED")
	
	var team_num = p.m.status.team_num
	if players.team_total_below_target(): return
	
	game_over(team_num)

func game_over(winning_team):
	print("GAME OVER")
	pass
