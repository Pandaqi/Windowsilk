extends Node2D

const RESPAWN_DELAY : float = 4.0

onready var main_node = get_node("/root/Main")
onready var web = get_node("/root/Main/Web")

onready var body = get_parent()
onready var timer = $Timer
onready var anim_player = $AnimationPlayer

var home_base

signal on_revive()

func plan_respawn():
	anim_player.play("Death")
	
func start_respawn():
	home_base = web.home_bases[body.m.status.team_num]
	home_base.m.homebase.update_stat("num_deaths", 1)
	
	teleport_to_home_base()
	lose_our_points()
	start_timer()
	play_animation()
	
	body.m.status.give_feedback("Respawn!")
	body.set_scale(Vector2(1,1))

func finish_respawn():
	stop_animation()
	
	emit_signal("on_revive")

func teleport_to_home_base():
	var params = {
		'nearby_point': home_base,
		'nearby_radius': 40
	}
	
	body.m.tracker.initialize(params)

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

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "Death": return
	start_respawn()
