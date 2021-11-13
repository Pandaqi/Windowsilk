extends Node2D

var type : String = ""
var last_known_edge = null
var last_known_point = null

var painting_allowed : bool = true
onready var timer = $Timer
onready var body = get_parent()

const BOSS_QUICK_PAINT_THRESHOLD : float = 5.0

func set_to(tp):
	if not tp: return
	type = tp

func reset():
	type = ""
	last_known_edge = null

func _on_Tracker_arrived_on_edge(e):
	last_known_edge = e
	
	var switched_to_new_edge = last_known_edge and (e != last_known_edge)
	if switched_to_new_edge and GlobalDict.cfg.paint_trails_when_jumping:
		paint()

func _on_Tracker_arrived_on_point(p):
	var exited_on_same_point = (p == last_known_point)
	
	last_known_point = p
	paint(exited_on_same_point)

func paint_specific_edge(e):
	last_known_edge = e
	paint()

func paint(exited_on_same_point = false):
	if not last_known_edge or not is_instance_valid(last_known_edge): return
	if not painting_allowed: return
	
	var temp_type = type
	if body.m.specialties.erase_silk_types():
		temp_type = "regular"
	
	if GlobalDict.cfg.players_leave_trail and body.m.status.is_player():
		var is_quick_paint = exited_on_same_point and body.m.specialties.get_time_on_edge() < BOSS_QUICK_PAINT_THRESHOLD
		var quick_paint_allowed = GlobalDict.cfg.allow_quick_paint
		
		if (not is_quick_paint) or quick_paint_allowed:
			last_known_edge.m.boss.set_to(body)
			return
	
	if temp_type == "": return
	last_known_edge.m.type.set_to(temp_type)
	
	disable_painting()

func disable_painting():
	painting_allowed = false
	timer.start()

func _on_Timer_timeout():
	painting_allowed = true

func _on_Status_on_death():
	reset()
