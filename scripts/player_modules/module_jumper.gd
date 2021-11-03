extends Node2D

const JUMP_DURATION : float = 0.5
const JUMP_SCALE : float = 1.3

const DIST_PER_SILK : float = 150.0

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
	return clamp(-round(dist / DIST_PER_SILK), -INF, -1)

func get_max_dist():
	return DIST_PER_SILK * body.m.silk.count()

func _on_Input_move_vec(vec, dt):
	if not active: return
	
	var no_input = (vec.length() <= 0.03)
	if no_input: return
	
	body.set_rotation(vec.angle())

func _on_Input_button_press():
	if input_disabled: return
	prepare_jump()

func _on_Input_button_release():
	if input_disabled: return
	execute_jump()

func get_forward_vec():
	var rot = body.rotation
	return Vector2(cos(rot), sin(rot))

func prepare_jump():
	if body.m.silk.is_empty(): return
	
	body.m.mover.disable()
	body.m.webtracker.disable_updates()
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
	var edge = body.m.webtracker.get_current_edge()
	if edge: exclude_bodies = [edge]
	
	var point = body.m.webtracker.get_current_point()
	if point: 
		exclude_bodies.append(point)
		exclude_bodies += point.get_edges()
	
	tween_data.target_point = null
	
	var res = edges.shoot(body.global_position, dir, exclude_bodies, edge, body)
	if res.failed:
		# TO DO: give feedback
		print("No jump possible")
		finish_jump()
		return

	tween_data.start_point = body.position
	tween_data.target_point = res.new_point

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
		body.m.silk.change(pay_for_travel(dist))
		
		body.m.webtracker.arrived_on_point(pos)

	body.m.mover.enable()
	body.m.webtracker.enable_updates()

func _on_Tween_tween_all_completed():
	finish_jump()
