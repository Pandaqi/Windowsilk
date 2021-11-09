extends Node2D

onready var web = $Web
onready var entities = $Entities
onready var players = $Players

var game_over_state : bool = false

func _ready():
	randomize()
	
	if GlobalInput.get_player_count() <= 0:
		GlobalInput.create_debugging_players()
	
	web.activate()

func web_loading_done():
	players.activate()
	entities.activate()
	
	web.assign_home_bases()

func on_player_death(p):
	if game_over_state: return
	
	print("PLAYER DIED")
	
	var teams_left = players.get_teams_left()
	if teams_left.size() > 1: return
	
	game_over(teams_left[0])

func on_player_progression(p):
	if game_over_state: return
	
	var team_num = p.m.status.team_num
	if players.team_total_below_target(team_num): return
	
	game_over(team_num)

func on_team_progression(team_num, points, needed_points):
	if points < needed_points: return
	if game_over_state: return
	
	game_over(team_num)

func on_team_won(team_num):
	game_over(team_num)

func game_over(winning_team):
	game_over_state = true
	
	print("GAME OVER")
	print("WINNING TEAM: " + str(winning_team))
	pass
