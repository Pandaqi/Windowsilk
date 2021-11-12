extends Node2D

const RESPAWN_DELAY : float = 4.0

onready var main_node = get_node("/root/Main")
onready var web = get_node("/root/Main/Web")

onready var body = get_parent()
onready var timer = $Timer
onready var anim_player = $AnimationPlayer

var home_base

signal on_revive()

func start_respawn():
	home_base = web.home_bases[body.m.status.team_num]
	home_base.m.homebase.update_stat("num_deaths", 1)
	
	body.m.status.give_feedback("Respawn!")
	
	teleport_to_home_base()
	decrease_opponent_objectives()
	lose_our_points()
	start_timer()
	play_animation()

func finish_respawn():
	stop_animation()
	
	emit_signal("on_revive")
	
	print("CUR EDGE")
	print(body.m.tracker.get_current_edge())
	
	print("INPUT ACTIVE")
	print(body.m.input.active)

func teleport_to_home_base():
	var params = {
		'nearby_point': home_base,
		'nearby_radius': 40
	}
	
	body.m.tracker.initialize(params)

func decrease_opponent_objectives():
	var all_bases = web.home_bases
	var team_num = body.m.status.team_num
	var winning_teams = []
	
	for b in all_bases:
		var its_our_home = (b == home_base)
		if its_our_home: continue
		
		b.m.homebase.change_target(-1)
		if b.m.homebase.should_win():
			winning_teams.append(b)
	
	if winning_teams.size() <= 0: return
	if winning_teams.size() == 1:
		main_node.on_team_won(team_num)
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
	
	main_node.on_team_won(best_team)

func start_timer():
	timer.wait_time = RESPAWN_DELAY
	timer.start()
	
func _on_Timer_timeout():
	finish_respawn()

func play_animation():
	anim_player.play("RespawnFlicker")

func stop_animation():
	anim_player.stop(true)

func lose_our_points():
	body.m.points.set_to(GlobalDict.cfg.point_reset_val)
