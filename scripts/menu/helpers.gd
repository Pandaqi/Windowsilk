extends Node2D

func _ready():
	for child in get_children():
		child.set_visible(false)

func _on_Players_player_logged_in():
	$Team.set_visible(true)

func _on_Main_team_changed(e):
	$Jump.set_visible(true)

func _on_Main_players_nearby(is_true, type):
	var node_name = type.capitalize()
	if not has_node(node_name): return
	get_node(node_name).set_visible(is_true)
