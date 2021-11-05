extends Node2D

const POINT_TARGET : int = 10

var entity_scene = preload("res://scenes/entity.tscn")
var players = []

func activate():
	var num_players = GlobalInput.get_player_count()
	for i in range(num_players):
		create_player(i)
	
	players = get_tree().get_nodes_in_group("Players")

func create_player(num):
	var p = entity_scene.instance()
	add_child(p)
	
	var team_num = num # for now;; read from "player_data" when I have menus
	p.m.status.set_type("player_spider") # for now;; different teams will have different types?
	p.m.status.make_player(num, team_num)
	
	var params = {
		'avoid_players': true
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
	for player in team:
		total += player.m.points.count()
	
	return total < num_players*POINT_TARGET
