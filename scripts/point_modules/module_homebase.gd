extends Node2D

var total_points : int = 0
var target_points : int = 0
var team : int = -1
var active : bool = false

onready var players = get_node("/root/Main/Players")
onready var main_node = get_node("/root/Main")

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
	
	update_label()
	update_sprite()
	
	set_visible(true)
	body.m.body.scale_collision_shape(2.0)

func update_label():
	var txt = str(total_points) + "/" + str(target_points)
	points_label.set_text(txt)

func update_sprite():
	sprite.set_frame(team)
	
	# Triangles ... always hard to center them nicely
	if team == 0:
		sprite.set_position(Vector2(0,-30))
		set_position(Vector2(0,10))

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
	
	print("Feedback; Safely stored points!")

func change_target(dt):
	target_points += dt
	update_label()

func should_win():
	return total_points >= target_points

func update_stat(key, val):
	team_stats[key] += val

func get_stat(key):
	if not team_stats.has(key): return 0
	return team_stats.key
