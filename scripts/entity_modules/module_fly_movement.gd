extends Node2D

const TIMER_BOUNDS = { 'min': 2, 'max': 6 }

var vec : Vector2

onready var movement_handler = get_parent()
onready var body = movement_handler.get_parent()
onready var area = $Area2D

onready var timer = $Timer

func initialize():
	_on_Timer_timeout()

func module_update(dt):
	check_area()
	movement_handler.emit_signal("move_vec", vec, dt)

func get_entities_near():
	var bodies = area.get_overlapping_bodies()
	for i in range(bodies.size()-1,-1,-1):
		if bodies[i] == self:
			bodies.remove(i)
			continue
		
		if bodies[i].m.status.is_dead:
			bodies.remove(i)
			continue
	
	return bodies

func check_area():
	var bodies = get_entities_near()
	if bodies.size() <= 0: return
	
	var vector = Vector2.ZERO
	var total_weight : float = 0.0
	var max_dist = area.get_node("CollisionShape2D").shape.radius
	
	for b in bodies:
		var body_is_a_threat = b.m.collector.can_collect(body)
		var body_is_food = body.m.collector.can_collect(b)
		var vec_to = (b.position - body.position)
		var weight = vec_to.length() / max_dist
		
		if movement_handler.has_fleeing_behavior() and body_is_a_threat:
			vector += -vec_to.normalized()*weight
			total_weight += weight
		
		if movement_handler.has_chasing_behavior() and body_is_food:
			vector += vec_to.normalized()*weight
			total_weight += weight
	
	if total_weight <= 0.05: return
	
	var avg_vector = vector/total_weight
	set_vector(avg_vector)

func custom_check_raycast(_entity_rc, web_rc):
	if not web_rc.is_colliding(): return
	move_away_from_bounds(web_rc)

func move_away_from_bounds(web_rc):
	# if we're about to hit the edge of the screen, rotate ourselves randomly AWAY from the bound
	var hit_body = web_rc.get_collider()
	if not hit_body.is_in_group("Bounds"): return
	
	var normal = web_rc.get_collision_normal()
	var rand_rot = (randf() - 0.35)*PI
	vec = normal.rotated(rand_rot)
	restart_timer()

func set_vector(new_vec):
	vec = new_vec

func pick_new_vec():
	var rot = 2*PI*randf()
	vec = Vector2(cos(rot), sin(rot))

func pick_opposite_vec():
	vec = -vec

func _on_Timer_timeout():
	restart_timer()
	pick_new_vec()

func restart_timer():
	timer.stop()
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func _on_Points_point_change(_val):
	pick_new_vec()
