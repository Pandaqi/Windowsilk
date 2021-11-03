extends Node2D

var player_scene = preload("res://scenes/player.tscn")

func activate():
	var num_players = GlobalInput.get_player_count()
	for i in range(num_players):
		create_player(i)

func create_player(num):
	var p = player_scene.instance()
	add_child(p)
	p.m.status.initialize(num)

func get_closest_dist(pos):
	return (get_closest(pos).position - pos).length()

func get_closest(pos):
	var players = get_tree().get_nodes_in_group("Players")
	
	var best = null
	var best_dist = INF
	
	for p in players:
		var dist = (p.position - pos).length()
		if dist < best_dist:
			best_dist = dist
			best = p
	
	return best
