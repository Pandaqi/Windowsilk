extends Node2D

const SLIPPERY_FACTOR : float = 3.0 # lower = more slippery
const TIMEBOMB_THRESHOLD : float = 5.0

const DURATION : float = 8.0
const NOISE_MAKER_FORCE : float = 100.0

const FEATHERLIGHT_SPEED : float = 0.1 # how fast points move inwards
const MARGIN_BEFORE_FEATHERLIGHT_STARTS : float = 20.0

var type : String = ""
var time_spent_on_edge : float = 0.0

onready var timer = $Timer
onready var icon = $Sprite
onready var body = get_parent()

var m = {}

func _ready():
	load_modules()
	hide_icon()

func load_modules():
	for child in $Modules.get_children():
		var key = child.name.to_lower()
		m[key] = child

func set_to(tp):
	if (not tp) or (tp == ""): return
	
	type = tp
	
	handle_immediate_effect()
	restart_timer()
	show_icon()

func reset():
	if m.has(type):
		m[type].deactivate()
	
	type = ""
	hide_icon()

func get_it():
	return type

func show_icon():
	var new_frame = GlobalDict.silk_types[type].frame
	icon.set_frame(new_frame)
	icon.set_visible(true)

func hide_icon():
	icon.set_visible(false)

func restart_timer():
	if not body.m.status.is_player(): return
	
	timer.wait_time = DURATION
	timer.start()

func _on_Timer_timeout():
	reset()

func handle_immediate_effect():
	if type == "": return
	if m.has(type):
		m[type].activate()

func handle_continuous_effect(dt):
	if type == "" and get_silk_type() == "": return
	
	handle_featherlight(dt)

# NOTE: if we immediately start changing points, we might get stuck on the starting point (as it just moved underneath us), so only start slightly later, works wonders
func handle_featherlight(dt):
	if not check_type("featherlight"): return
	
	var cur_edge = body.m.silkreader.cur_edge
	if not cur_edge or not is_instance_valid(cur_edge): return
	
	var far_enough_on_edge = (cur_edge.m.body.get_dist_to_closest_point(body) > MARGIN_BEFORE_FEATHERLIGHT_STARTS)
	if not far_enough_on_edge: return
	
	cur_edge.m.body.move_extremes_inward(FEATHERLIGHT_SPEED, dt)

func hijack_jump_press():
	if check_type("noisemaker") or check_type("attractor"): return true
	return false

func hijack_jump_release():
	if check_type("noisemaker") or check_type("attractor"): 
		execute_blastarea_effect()
		return true
	return false

func _physics_process(dt):
	reposition_icon()
	handle_continuous_effect(dt)

func reposition_icon():
	icon.set_position(Vector2(0,-43).rotated(-body.rotation))
	icon.set_rotation(-body.rotation)

func jumping_is_free():
	return check_type("trampoline")

func erase_silk_types():
	return check_type("regular")

func modify_points(val):
	if check_type("doubler"): val *= 2
	elif check_type("worthless"): val = 0
	return val

func check_type(tp):
	return type == tp or get_silk_type() == tp

func get_silk_type():
	return body.m.silkreader.cur_silk_type

func modify_input_vec(start_vec, target_vec, dt):
	if start_vec.length() <= 0.03: return target_vec
	if not check_type("slippery"): return target_vec
	
	return start_vec.slerp(target_vec, SLIPPERY_FACTOR * dt)

func modify_speed(new_vec, new_speed, input_vec):
	if check_type("speedy"): new_speed *= 1.5
	elif check_type("slowy"): new_speed *= 0.5
	
	if check_type("slippery"):
		new_speed *= (new_vec.dot(input_vec)+1)*0.5

	return new_vec * new_speed

func jumping_is_forbidden():
	return check_type("sticky")

func jumping_is_aggressive():
	return check_type("aggressor")

func can_be_eaten():
	if check_type("shield"): return false
	return true

func can_eat_anything():
	return check_type("gobbler")

func update_time_spent_on_edge(dt):
	time_spent_on_edge += dt
	if time_spent_on_edge > TIMEBOMB_THRESHOLD:
		if check_type("time_loser"):
			body.m.points.change(-1)
		elif check_type("time_gainer"):
			body.m.points.change(+1)
		
		time_spent_on_edge = 0.0
	
func _on_Tracker_arrived_on_edge(e):
	time_spent_on_edge = 0.0

func execute_blastarea_effect():
	var bodies = $BlastArea.get_overlapping_bodies()
	var dir = 1
	if check_type("attractor"): dir = -1
	
	for b in bodies:
		var its_us = (b == body)
		if its_us: continue
		
		if not b.is_in_group("Entities"): continue
		
		var vec_away = (b.position - body.position).normalized()
		b.m.knockback.apply(dir * vec_away * NOISE_MAKER_FORCE)
