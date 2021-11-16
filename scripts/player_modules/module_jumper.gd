extends Node2D

const JUMP_DISTANCE_PER_SECOND : float = 750.0
const JUMP_SCALE : float = 1.3
const FLY_JUMP_DIST : float = 80.0

const DIST_PER_POINT : float = 185.0

var active : bool = false
var input_disabled : bool = false

onready var body = get_parent()
onready var edges = get_node("/root/Main/Web").edges
onready var arena = get_node("/root/Main/Arena")
onready var tween = $Tween

onready var aim_helper = $AimHelper

var jump_data = {
	'target_point': null,
	'start_point': null,
	'find_valid_dir': false,
	'dont_create_new_edges': false
}

signal on_jump_finished()

func pay_for_travel(dist):
	if body.m.specialties.jumping_is_free(): return 0

	var payment = clamp(-round(dist / DIST_PER_POINT), -INF, -1)
	return payment

func get_max_dist():
	if body.is_in_group("Players"):
		if body.m.specialties.jumping_is_free():
			return 5000.0
		
		return DIST_PER_POINT * body.m.points.count()
	
	# TO DO: Or ... simply make them use the same system as players? (The more points they have, the further they can jump?) And potentially SCALE that, if needed?
	var data = body.m.status.data
	if data.move.has('jump_dist'):
		return data.move.jump_dist
	
	var move_type = body.m.status.get_move_type()
	if move_type == "fly": 
		return FLY_JUMP_DIST
	
	return 5000.0

func disable_input():
	input_disabled = true

func _on_Input_move_vec(vec, dt):
	if not active: return
	
	# NOTE: It's common for players to release their aim too soon, causing it to change _just_ before jumping => this prevents that, mostly. 
	var deadzone = 0.5
	var not_enough_input = (vec.length() <= deadzone)
	if not_enough_input: return

	var input_vec = body.m.specialties.modify_input_vec(get_forward_vec(), vec, dt)
	body.set_rotation(input_vec.angle())

func _on_Input_button_press():
	if input_disabled: return
	if body.m.specialties.jumping_is_forbidden(): return
	
	var res = body.m.specialties.hijack_jump_press()
	if res: return
	
	prepare_jump()

func _on_Input_button_release(params = {}):
	if input_disabled: return
	
	# NOTE: important to do this BEFORE the "active" check, as a hijacked jump will not be active
	var res = body.m.specialties.hijack_jump_release()
	if res: 
		finish_fake_jump()
		return
	
	# if we never started the jump, don't do anything when we release
	if not active: return 
	
	for key in params:
		jump_data[key] = params[key]
	
	execute_jump()

func get_forward_vec():
	var rot = body.rotation
	return Vector2(cos(rot), sin(rot))

func update_aim_helper(col):
	aim_helper.modulate = col

func prepare_jump():
	if body.is_in_group("Players"): 
		if body.m.points.is_empty() and not body.m.specialties.jumping_is_free():
			body.m.status.give_feedback("Need points!")
			return
	
	body.m.mover.disable()
	body.m.tracker.disable()
	
	aim_helper.set_visible(true)
	
	active = true

func execute_jump():
	if not active: return
	
	aim_helper.set_visible(false)
	
	active = false
	input_disabled = true
	
	jump_data.start_pos = body.position
	jump_data.start_point = null
	
	jump_data.target_pos = null
	jump_data.target_point = null

	var params = determine_jump_details()
	if jump_data.find_valid_dir:
		var new_vec = find_valid_jumping_dir(params)
		body.set_rotation(new_vec.angle())
		params.dir = new_vec
	
	if params.move_type == "web":
		shoot_silk_line(params)
	else:
		jump_data.target_pos = body.position + get_forward_vec()*FLY_JUMP_DIST
	
	var actually_jumped = (jump_data.target_pos != null)
	if actually_jumped:
		var dist = (jump_data.target_pos - jump_data.start_pos).length()
		if body.is_in_group("Players"):
			body.m.points.change(pay_for_travel(dist))
		
		body.m.tracker.remove_from_all()
		
			
		GlobalAudio.play_dynamic_sound(body, "whoosh")
		if body.m.status.is_player():
			GlobalAudio.play_dynamic_sound(body, "web_create")
		
	play_jump_tween()

func determine_jump_details():
	var dir = get_forward_vec()
	var move_type = body.m.status.get_move_type()
	jump_data.move_type = move_type
	
	var exclude_bodies = [body]
	var edge = body.m.tracker.get_current_edge()
	if edge: exclude_bodies = [edge]
	
	var point = body.m.tracker.get_current_point()
	if point: 
		exclude_bodies.append(point)
		exclude_bodies += point.m.edges.get_them()
	
	var params = {
		'move_type': move_type,
		'from': body.position,
		'dir': dir,
		'max_dist': get_max_dist(),
		'exclude': exclude_bodies,
		'origin_edge': edge,
		'shooter': body,
		'destroy': body.m.specialties.jumping_is_aggressive(),
		'dont_create_new_edges': jump_data.dont_create_new_edges
	}
	
	return params

func shoot_silk_line(params):
	var res = edges.shoot(params)
	if res.failed:
		body.m.status.give_feedback("No jump possible")
		finish_jump()
		return
	
	if res.destroy:
		finish_jump()
		return
	
	if res.new_edge:
		res.new_edge.m.boss.set_to(body, false)
		res.new_edge.m.type.set_to('regular')

	jump_data.target_pos = res.to.pos
	jump_data.target_point = res.to.point
	jump_data.target_edge = res.to_edge

func play_jump_tween():
	var target = jump_data.target_pos
	if jump_data.target_point: target = jump_data.target_point.position
	
	if not target: return
	
	var distance = (target - body.position).length()
	var dur = distance / JUMP_DISTANCE_PER_SECOND
	
	tween.interpolate_property(body, "position",
		body.position, target, dur,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	tween.interpolate_property(body, "scale",
		Vector2(1,1), Vector2(1,1)*JUMP_SCALE, 0.5*dur,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
	tween.interpolate_property(body, "scale",
		Vector2(1,1)*JUMP_SCALE, Vector2(1,1), 0.5*dur,
		Tween.TRANS_LINEAR, Tween.EASE_OUT,
		0.5*dur)
	
	tween.start()

func finish_fake_jump():
	emit_signal("on_jump_finished")

func finish_jump():
	input_disabled = false
	
	handle_new_position_in_web()
	
	var we_died_during_jump = body.m.status.is_dead
	if we_died_during_jump: return

	body.m.mover.enable()
	body.m.tracker.enable()
	
	arena.execute_knockback(body.position)
	
	emit_signal("on_jump_finished")

func handle_new_position_in_web():
	if jump_data.move_type != "web": return
	
	#var start_pos = jump_data.start_pos
	var target_pos = jump_data.target_pos
	var actually_jumped = (target_pos != null)
	if not actually_jumped: return
	
	var no_valid_edge = (not jump_data.target_edge) or (not is_instance_valid(jump_data.target_edge))
	var no_valid_point = (not jump_data.target_point) or (not is_instance_valid(jump_data.target_point))
	var target_has_disappeared = no_valid_edge and no_valid_point
	
	if target_has_disappeared:
		body.m.status.die()
		return

	if jump_data.target_point:
		body.m.tracker.arrived_on_point(jump_data.target_point)
		return
	
	if jump_data.target_edge and is_instance_valid(jump_data.target_edge):
		if jump_data.dont_create_new_edges:
			body.m.tracker.force_set_edge(jump_data.target_edge)
			return
		else:
			body.m.tracker.arrived_on_edge(jump_data.target_edge)
			return

func _on_Tween_tween_all_completed():
	finish_jump()

func _on_Jumper_on_instant_jump(params):
	for key in params:
		jump_data[key] = params[key]
	
	var res = body.m.specialties.hijack_jump_release()
	if res: return
	
	prepare_jump()
	execute_jump()

func get_random_vec():
	var rot = 2*PI*randf()
	return Vector2(cos(rot), sin(rot))

func is_dir_valid(params):
	var space_state = get_world_2d().direct_space_state
	
	var epsilon = 3.0
	var to = params.from + params.dir*params.max_dist
	var col_layer = 1

	# check where we should land
	# the edges of the map always have bounds, so we always stop at the edge (if we hit nothing else)
	var result = space_state.intersect_ray(params.from + params.dir*epsilon, to, params.exclude, col_layer)
	if not result: return false
	if result.collider.is_in_group("Bounds"): return false
	
	var dist_to_target = (result.collider.position - params.from).length() 
	var margin = 20
	
	# now check for entities that might eat us along this route
	# (change collision layers + shorten raycast to stop after our target point)
	col_layer = 2 + 4
	to = params.from + params.dir*(dist_to_target+margin)
	result = space_state.intersect_ray(params.from + params.dir*epsilon, to, params.exclude, col_layer)
	
	if result and result.collider.m.collector.can_collect(body, false): return false
	
	return true

func find_valid_jumping_dir(params):
	var bad_direction : bool = true

	while bad_direction:
		params.dir = get_random_vec()
		if not is_dir_valid(params): continue
		
		bad_direction = false
	
	return params.vec

func _on_Status_on_death():
	if tween.is_active():
		tween.stop_all()
	
	input_disabled = false
	aim_helper.set_visible(false)
