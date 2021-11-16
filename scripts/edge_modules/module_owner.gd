extends Node2D

const PAINT_VOLUME : float = -6.0
const MAX_PLAYER_STUCK_TIME : float = 15.0

var boss = null
var total_wait_time : float = 20.0

onready var body = get_parent() 
onready var timer = $Timer

func set_to_specific_time(tm):
	if not boss: return
	if tm <= 0.0: return
	
	timer.wait_time = tm
	timer.start()

func set_to(b, short = true):
	if not b: return
	
	boss = b
	GlobalAudio.play_dynamic_sound(body, "web_paint", PAINT_VOLUME)
	
	body.m.drawer.set_pattern(boss.m.status.team_num)
	start_timer(short)

func get_it():
	return boss

func has_one():
	return (boss != null)

func is_safe_for(node):
	# obviously, one can walk over edges that are yours
	if node.m.status.team_num == boss.m.status.team_num:
		return true
	
	# but this is a fail-safe to prevent players from being stuck (and unable to _play_ te game) for a long period of time
	if node.m.status.is_player() and timer.time_left > MAX_PLAYER_STUCK_TIME:
		return true
	
	return false

func reset():
	boss = null
	body.m.drawer.remove_pattern()
	body.m.entities.unstuck_players()

func can_enter(entity):
	if not boss: return true
	if entity.is_in_group("NonPlayers") and GlobalDict.cfg.ai_can_enter_owned_silk: return true
	
	# handles the Lowlife specialty => both silk type and powerup
	if body.m.type.equals("lowlife") and entity.m.specialties.has_one(): 
		entity.m.status.give_constant_feedback("Can't enter with powerup!")
		return false
		
	if entity.m.specialties.check_type("lowlife") and body.m.type.is_special():
		entity.m.status.give_constant_feedback("Can't enter special lines!")
		return false
	
	if boss.m.status.team_num != entity.m.status.team_num:
		entity.m.status.give_constant_feedback("Owned by someone else!")
		return false
	
	return true

# TO DO: Might put this on a slower timer, as we really don't need this precision/speed of updates
func _physics_process(_dt):
	body.m.drawer.fade_icons(get_fade_ratio())

func get_time_left():
	return timer.time_left

func get_fade_ratio():
	return clamp(get_time_left() / total_wait_time, 0.2, 1.0)

func start_timer(short):
	total_wait_time = GlobalDict.cfg.short_owner_fade_time
	if not short: total_wait_time = GlobalDict.cfg.long_owner_fade_time
	
	timer.wait_time = total_wait_time
	timer.start()

func _on_Timer_timeout():
	reset()
