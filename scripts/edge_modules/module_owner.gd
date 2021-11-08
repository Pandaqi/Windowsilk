extends Node2D

const OWNER_FADE_TIME : float = 20.0

var boss = null

onready var body = get_parent() 
onready var timer = $Timer

func set_to(b):
	if not b: return
	
	boss = b
	
	body.m.drawer.set_pattern(boss.m.status.team_num)
	start_timer()

func get_it():
	return boss

func has_one():
	return (boss != null)

func reset():
	boss = null
	body.m.drawer.remove_pattern()

func can_enter(entity):
	if not boss: return true
	if entity.is_in_group("NonPlayers") and GlobalDict.cfg.ai_can_enter_owned_silk: return true
	
	# handles the Lowlife specialty => both silk type and powerup
	if body.m.type.equals("lowlife") and entity.m.specialties.has_one(): return false
	if entity.m.specialties.check_type("lowlife") and body.m.type.is_special(): return false
	
	return boss.m.status.team_num == entity.m.status.team_num

# TO DO: Might put this on a slower timer, as we really don't need this precision/speed of updates
func _physics_process(dt):
	body.m.drawer.fade_icons(get_fade_ratio())

func get_fade_ratio():
	return timer.time_left / OWNER_FADE_TIME

func start_timer():
	timer.wait_time = OWNER_FADE_TIME
	timer.start()

func _on_Timer_timeout():
	reset()
