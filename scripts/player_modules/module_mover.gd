extends Node2D

const BASE_SPEED : float = 170.0
const DELAY_AT_POINT : float = 0.1

var speed : float = BASE_SPEED

onready var body = get_parent()
onready var point_delay_timer = $PointDelayTimer

var can_move_from_point : bool = false
var active : bool = true

func _on_Input_move_vec(vec, dt):
	if not active: return

	var not_moving = (vec.length() <= 0.03)
	if not_moving: return

	move_along_web(vec, dt)

func move_along_web(vec, dt):
	var res = try_edge_move(vec, dt)
	if res: return
	
	res = try_point_move(vec, dt)

func try_edge_move(vec, dt):
	var edge = body.m.webtracker.get_current_edge()
	if not edge: return false
	
	var cur_edge_vec : Vector2 = edge.m.body.get_vec().normalized()
	var dot_prod : float = vec.normalized().dot(cur_edge_vec)
	
	var final_move_vec : Vector2 = cur_edge_vec
	if dot_prod < 0: final_move_vec *= -1
	
	var final_move_speed = speed
	if edge.m.type.equals('speedy'): final_move_speed *= 1.5
	elif edge.m.type.equals('slowy'): final_move_speed *= 0.5

	body.move_and_collide(final_move_vec * final_move_speed * dt)
	body.set_rotation(final_move_vec.angle())
	
	# NOTE: the "entity on me" check can, in rare occassions, fail
	# So, we also check if we're close enough to the point at which we should be arriving
	# Otherwise we call it a fluke and continue
	if not edge.m.entities.is_on_me(body):
		var closest_point = edge.m.body.get_closest_point(body)
		if (body.position - closest_point.position).length() <= 5.0:
			body.m.webtracker.arrived_on_point(closest_point)
			return false
	
	return true

func try_point_move(vec, dt):
	if not can_move_from_point: return
	
	var point = body.m.webtracker.get_current_point()
	if not point: return false
	
	var best_edge = point.find_edge_closest_to_vec(vec)
	body.m.webtracker.arrived_on_edge(best_edge)

	return true

func enter_point(p):
	point_delay_timer.wait_time = DELAY_AT_POINT
	point_delay_timer.start()
	can_move_from_point = false

func enter_edge(e):
	pass

func disable():
	active = false

func enable():
	active = true

func set_speed(sp):
	speed = sp

func _on_PointDelayTimer_timeout():
	can_move_from_point = true

func _on_Input_button_release():
	pass # Replace with function body.

func _on_Input_button_press():
	pass # Replace with function body.

func _on_WebTracker_arrived_on_edge(e):
	enter_edge(e)

func _on_WebTracker_arrived_on_point(p):
	enter_point(p)
