extends Node2D

onready var web = get_node("/root/Main/Web")

var entity_scene = preload("res://scenes/entity.tscn")
var players = []

func prepare():
	var num_players = GlobalInput.get_player_count()
	players = []
	for i in range(num_players):
		create_player(i)

func activate():
	for i in range(players.size()):
		place_player(players[i])

func create_player(num):
	var p = entity_scene.instance()
	web.entities.add_child(p)
	
	var team_num = GlobalDict.player_data[num].team
	p.m.status.set_type("player_spider")
	p.m.status.make_player(num, team_num)
	
	players.append(p)

func place_player(p):
	var home_base_point = web.home_bases[p.m.status.team_num]
	var params = {
		'nearby_point': home_base_point,
		'nearby_radius': 40,
	}
	p.m.status.initialize(params)

func get_closest_dist(pos):
	if players.size() <= 0: return INF
	return (get_closest(pos).position - pos).length()

func get_closest(pos):
	if players.size() <= 0: return null
	
	var best = null
	var best_dist = INF
	
	for p in players:
		var dist = (p.position - pos).length()
		if dist < best_dist:
			best_dist = dist
			best = p
	
	return best

func get_teams_in_play():
	var data = GlobalDict.player_data
	var teams = []
	for d in data:
		if not d.active: continue
		
		var team_num = d.team
		if team_num in teams: continue
		teams.append(team_num)
	
	return teams

func get_teams_left():
	var teams_left = []
	for p in players:
		if p.m.status.is_dead: continue
		
		var team_num = p.m.status.team_num
		if team_num in teams_left: continue
		
		teams_left.append(team_num)
	
	return teams_left

func get_players_in_team(team_num : int):
	var team = []
	for p in players:
		var temp_team_num = p.m.status.team_num
		if temp_team_num != team_num: continue
		team.append(p)
	return team

func team_total_below_target(team_num):
	var total = 0
	var team = get_players_in_team(team_num)
	var num_players = team.size()
	if num_players <= 0: return true
	
	for player in team:
		total += player.m.points.count()

	return total < num_players*GlobalDict.cfg.objective_points_per_player
