extends Node2D

const DELAY_AT_POINT : float = 0.1

onready var mover_handler = get_parent()
onready var body = mover_handler.get_parent()
onready var point_delay_timer = $PointDelayTimer

var can_move_from_point : bool = false
var last_velocity : Vector2 = Vector2.RIGHT

var cur_vec : Vector2 = Vector2.ZERO
var desired_vec : Vector2 = Vector2.ZERO

func _on_Input_move_vec(vec, dt):
	desired_vec = vec

func stop():
	desired_vec = Vector2.ZERO

func module_update(dt):
	var cur_pos = body.position
	var final_vec = body.m.specialties.modify_input_vec(cur_vec, desired_vec, dt)
	move_along_web(final_vec, dt)

	cur_vec = final_vec
	
	var new_pos = body.position
	mover_handler.emit_signal("on_move_completed", (new_pos - cur_pos))

func move_along_web(vec, dt):
	if vec.length() <= 0.03: 
		return
	
	if body.m.tracker.no_valid_web_position():
		body.m.status.die()
		return 

	var res = try_edge_move(vec, dt)
	if res: return
	
	res = try_point_move(vec, dt)

func try_edge_move(vec, dt):
	var edge = body.m.tracker.get_current_edge()
	if not edge: return false

	var cur_edge_vec : Vector2 = edge.m.body.get_vec().normalized()
	var input_vec = vec

	var dot_prod : float = input_vec.normalized().dot(cur_edge_vec)
	var final_move_vec : Vector2 = cur_edge_vec
	if dot_prod < 0: final_move_vec *= -1
	body.set_rotation(final_move_vec.angle())
	
	var final_move_speed = mover_handler.get_final_speed()
	final_move_vec = body.m.specialties.modify_speed(final_move_vec, final_move_speed, input_vec)

	var new_velocity = final_move_vec * dt
	var prevent_movement = body.m.visuals.worm.receive_move_vector(new_velocity)

	if not prevent_movement:
		body.move_and_collide(new_velocity)

	last_velocity = new_velocity
	
	var res = did_we_walk_off_the_edge(edge)
	if res: return false
	
	return true

# NOTE: the "entity on me" check can, in rare occassions, fail
# So, we also check if we're close enough to the point at which we should be arriving
# Otherwise we call it a fluke and continue
func did_we_walk_off_the_edge(edge):
	if edge.m.entities.is_on_me(body): return false
	
	var closest_point = edge.m.body.get_closest_point(body)
	if (body.position - closest_point.position).length() > 5.0: return false

	body.m.tracker.arrived_on_point(closest_point)
	return true

func try_point_move(vec, _dt):
	if not can_move_from_point: return
	
	var point = body.m.tracker.get_current_point()
	if not point or not is_instance_valid(point): return false
	
	var best_edge = point.m.edges.find_closest_to_vec(vec)
	if not best_edge: return false
	
	if not best_edge.m.boss.can_enter(body):
		print("Can't enter; owned by someone else")
		return false
	
	if best_edge.m.type.direction_forbidden(vec): 
		print("Feedback: One way edge!")
		return false
	
	body.m.tracker.arrived_on_edge(best_edge)

	return true

func enter_point(_p):
	delay_continued_travel()

func enter_edge(_e):
	pass

func delay_continued_travel():
	var delay = DELAY_AT_POINT
	if body.m.status.data.move.has('always'): delay = 0.01
	
	point_delay_timer.wait_time = delay
	point_delay_timer.start()
	can_move_from_point = false

func _on_PointDelayTimer_timeout():
	can_move_from_point = true

func _on_Tracker_arrived_on_edge(e):
	enter_edge(e)

func _on_Tracker_arrived_on_point(p):
	enter_point(p)
