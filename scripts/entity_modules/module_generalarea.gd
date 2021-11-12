extends Area2D

var num_overlapping_bounds : int = 0
var near_home_base : bool = false
var players_near : int = 0

onready var body = get_parent()

signal on_nearby_players_changed(val)

func activate():
	check_players_near()

func out_of_bounds():
	return (num_overlapping_bounds > 0)

func _on_GeneralArea_body_entered(other_body):
	if other_body.is_in_group("Bounds"): num_overlapping_bounds += 1
	if other_body.is_in_group("Points"):
		if other_body.m.homebase.is_mine(body):
			near_home_base = true

func _on_GeneralArea_body_exited(other_body):
	if other_body.is_in_group("Bounds"): num_overlapping_bounds -= 1
	if other_body.is_in_group("Points"):
		if other_body.m.homebase.is_mine(body):
			near_home_base = false

func check_players_near():
	if body.m.status.is_player(): return
	
	var show = (players_near > 0)
	emit_signal("on_nearby_players_changed", show)

func has_protection_from_home_base():
	if not body.m.status.is_player(): return false
	return near_home_base

func _on_PlayerArea_body_entered(other_body):
	if other_body.is_in_group("Players"):
		players_near += 1
		check_players_near()

func _on_PlayerArea_body_exited(other_body):
	if other_body.is_in_group("Players"):
		players_near -= 1
		check_players_near()
