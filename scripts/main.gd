extends Node2D

onready var web = $Web
onready var entities = $Entities
onready var players = $Players
onready var gui = $GUI
onready var arena = $Arena

var game_over_state : bool = false

# DEBUGGING QUICK GAME OVER
#func _input(ev):
#	if ev.is_action_released("ui_up"):
#		game_over(0)

func _ready():
	randomize()
	
	if GlobalInput.get_player_count() <= 0:
		GlobalInput.create_debugging_players()
	
	web.activate()

func web_loading_done():
	arena.activate()
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
	if game_over_state: return
	
	game_over_state = true
	
	var players_in_team = players.get_players_in_team(winning_team)
	for p in players_in_team:
		p.m.status.make_winner()
	
	gui.activate_game_over(winning_team)
