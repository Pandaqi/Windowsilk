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
	
	GlobalInput.create_debugging_players()
	
	arena.activate()
	web.activate()

func web_loading_done():
	players.prepare()
	web.assign_home_bases()
	players.activate()
	
	arena.prepare_entity_placement()
	entities.activate()

	arena.web_loading_done()

func on_player_death(_p):
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
	GlobalAudio.play_static_sound("win_game")
	
	game_over(team_num)

func decrease_opponent_objectives(body):
	if not body.m.status.is_player(): return
	
	var all_bases = web.home_bases
	var team_num = body.m.status.team_num
	var home_base = web.home_bases[team_num]
	var winning_teams = []
	
	for b in all_bases:
		var its_our_home = (b == home_base)
		if its_our_home: continue
		
		b.m.homebase.change_target(-1)
		if b.m.homebase.should_win():
			winning_teams.append(b)
	
	if winning_teams.size() <= 0: return
	if winning_teams.size() == 1:
		on_team_won(team_num)
		return
	
	# use number of deaths as a tiebreaker
	# if that is still equal, it's just team num order
	var best_team = -1
	var lowest_val = INF
	
	for t in winning_teams:
		var num_deaths = t.m.homebase.get_stat("num_deaths")
		if num_deaths < lowest_val:
			lowest_val = num_deaths
			best_team = t.m.homebase.team_num
	
	on_team_won(best_team)

func game_over(winning_team):
	if game_over_state: return
	
	game_over_state = true
	
	var players_in_team = players.get_players_in_team(winning_team)
	for p in players_in_team:
		p.m.status.make_winner()
	
	gui.activate_game_over(winning_team)
