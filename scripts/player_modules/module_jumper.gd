extends Node2D

const JUMP_DURATION : float = 0.5
const JUMP_SCALE : float = 1.3

const DIST_PER_POINT : float = 150.0

var active : bool = false
var input_disabled : bool = false

onready var body = get_parent()
onready var edges = get_node("/root/Main/Web").edges
onready var tween = $Tween

var tween_data = {
	'target_point': null,
	'start_point': null
}

func pay_for_travel(dist):
	if body.m.silkreader.jumping_is_free(): return 0
	
	var payment = clamp(-round(dist / DIST_PER_POINT), -INF, -1)
	return payment

func get_max_dist():
	return DIST_PER_POINT * body.m.points.count()

func _on_Input_move_vec(vec, dt):
	if not active: return
	
	# NOTE: It's common for players to release their aim too soon, causing it to change _just_ before jumping => this prevents that, mostly. 
	var deadzone = 0.5
	var not_enough_input = (vec.length() <= deadzone)
	if not_enough_input: return
	
	var input_vec = body.m.silkreader.modify_input_vec(vec)
	body.set_rotation(input_vec.angle())

func _on_Input_button_press():
	if input_disabled: return
	if body.m.silkreader.jumping_is_forbidden(): return
	prepare_jump()

func _on_Input_button_release():
	if input_disabled: return
	if not active: return # if we never started the jump, don't do anything when we release
	execute_jump()

func get_forward_vec():
	var rot = body.rotation
	return Vector2(cos(rot), sin(rot))

func prepare_jump():
	if body.m.points.is_empty(): return
	
	body.m.mover.disable()
	body.m.tracker.disable()
	
	active = true

func execute_jump():
	if not active: return
	
	active = false
	input_disabled = true
	create_new_silk_line()
	play_jump_tween()

func create_new_silk_line():
	var dir = get_forward_vec()
	
	var exclude_bodies = []
	var edge = body.m.tracker.get_current_edge()
	if edge: exclude_bodies = [edge]
	
	var point = body.m.tracker.get_current_point()
	if point: 
		exclude_bodies.append(point)
		exclude_bodies += point.get_edges()
	
	tween_data.target_point = null
	
	var params = {
		'from': body.position,
		'dir': dir,
		'exclude': exclude_bodies,
		'origin_edge': edge,
		'shooter': body,
		'destroy': body.m.silkreader.jumping_is_aggressive()
	}

	var res = edges.shoot(params)
	if res.failed or res.destroy or not res.new_edge:
		# TO DO: give feedback => and differentiate, as these cases are really not the same
		print("No jump possible or needed")
		finish_jump()
		return
	
	res.new_edge.m.boss.set_to(body)
	res.new_edge.m.type.set_to('regular')

	tween_data.start_point = body.position
	tween_data.target_point = res.to.point

func play_jump_tween():
	if not tween_data.target_point: return
	
	var dur = JUMP_DURATION
	tween.interpolate_property(body, "position",
		body.position, tween_data.target_point.position, dur,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	tween.interpolate_property(body, "scale",
		Vector2(1,1), Vector2(1,1)*JUMP_SCALE, 0.5*dur,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
	tween.interpolate_property(body, "scale",
		Vector2(1,1)*JUMP_SCALE, Vector2(1,1), 0.5*dur,
		Tween.TRANS_LINEAR, Tween.EASE_OUT,
		0.5*dur)
	
	tween.start()

func finish_jump():
	input_disabled = false
	
	var pos = tween_data.target_point
	var start_pos = tween_data.start_point
	
	var actually_jumped = (pos and start_pos)
	if actually_jumped:
		var dist = (pos.position - start_pos).length()
		body.m.points.change(pay_for_travel(dist))
		
		body.m.tracker.arrived_on_point(pos)

	body.m.mover.enable()
	body.m.tracker.enable()

func _on_Tween_tween_all_completed():
	finish_jump()
