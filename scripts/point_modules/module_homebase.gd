extends Node2D

var total_points : int = 0
var target_points : int = 0
var team : int = -1
var active : bool = false

onready var players = get_node("/root/Main/Players")
onready var main_node = get_node("/root/Main")

var player_sprite = preload("res://scenes/ui/player_icon.tscn")
onready var icon_container = $IconContainer

onready var points_label = $Points/Points
onready var sprite = $Sprite
onready var body = get_parent()

var team_stats = {
	"num_deaths": 0
}

func activate(num):
	team = num
	active = true
	
	var num_players = players.get_players_in_team(num).size()
	target_points = num_players * GlobalDict.cfg.objective_points_per_player
	
	create_player_sprites()
	update_label()
	update_sprite()
	
	set_visible(true)
	body.m.body.scale_collision_shape(2.0)

func create_player_sprites():
	var players_in_team = players.get_players_in_team(team)
	var icon_size = 32
	var offset = -0.5*(players_in_team.size() - 1)*icon_size
	
	var i = 0
	for p in players_in_team:
		var player_num = p.m.status.player_num
		var color = GlobalDict.player_data[player_num].color
		
		var icon = player_sprite.instance()
		icon.modulate = color
		icon_container.add_child(icon)
		icon.set_position((offset + i * icon_size) * Vector2.RIGHT)
		
		i += 1

func update_label():
	var txt = str(total_points) + "/" + str(target_points)
	points_label.set_text(txt)

func update_sprite():
	sprite.set_frame(team)
	
	# Triangles ... always hard to center them nicely
	if team == 0:
		sprite.set_position(Vector2(0,-30))
		set_position(Vector2(0,10))
		icon_container.position.y *= -1

func update_total(dp):
	total_points += dp
	update_label()
	
	main_node.on_team_progression(team, total_points, target_points)

func check_player_entrance(p):
	if not active: return
	if not p.is_in_group("Players"): return
	if p.m.status.team_num != team: return
	
	var num_points = p.m.points.count()
	var reset_val = GlobalDict.cfg.point_reset_val
	var actual_point_change = (num_points - reset_val)
	
	if actual_point_change <= 0: return
	
	update_total(actual_point_change)
	p.m.points.set_to(reset_val)
	
	p.m.status.give_feedback("Stored!")
	p.m.status.play_sound("store_points")

func change_target(dt):
	target_points += dt
	update_label()

func should_win():
	return total_points >= target_points

func is_active():
	return active

func is_mine(node):
	return node.m.status.team_num == team

func update_stat(key, val):
	team_stats[key] += val

func get_stat(key):
	if not team_stats.has(key): return 0
	return team_stats.key
