extends Node2D

var entities = []

var entities_passed : int = 0
var total_time : float = 0.0

var TIMEBOMB_BOUNDS = { 'min': 1, 'max': 7 }
var rand_timebomb_threshold : float = 0

onready var body = get_parent()

func _ready():
	rand_timebomb_threshold = rand_range(TIMEBOMB_BOUNDS.min, TIMEBOMB_BOUNDS.max)

func add(e):
	entities.append(e)
	entities_passed += 1
	
#	if body.m.type.equals("timebomb") and entities_passed > rand_entity_threshold:
#		body.m.body.self_destruct()

func remove(e):
	entities.erase(e)
	
	var edge_is_fragile = (body.m.type.equals("fragile") and entities_passed > 0)
	var entity_makes_fragile = (e.is_in_group("Players") and e.m.specialties.check_type("fragile"))
	if edge_is_fragile or entity_makes_fragile:
		body.m.body.self_destruct()

# TO DO: It's way better for performance to just save the time we "enter" a new edge, and then compare it to the current time, but there's currently no 100% correct system for checking an edge switch.
func _physics_process(dt):
	for e in entities:
		e.m.specialties.update_time_spent_on_edge(dt)
		total_time += dt
	
	if body.m.type.equals("timebomb") and total_time > rand_timebomb_threshold:
		body.m.body.self_destruct()

func get_them():
	return entities

func update_positions():
	for e in entities:
		e.m.tracker.update_positions()

func pull_towards_center_if_close_to_edge(speed, dt):
	var center = body.m.body.get_center()
	for entity in entities:
		var dist = body.m.body.get_dist_to_closest_point(entity)
		
		if dist > 30: continue
		
		var vec_to_center = (center - entity.position).normalized() * speed
		entity.m.mover.try_edge_move(vec_to_center, dt)

func is_on_me(e, epsilon = 5.0):
	var start_pos = body.m.body.start.position
	var end_pos = body.m.body.end.position
	
	return body.m.body.point_is_between(start_pos, end_pos, e.position, epsilon)

func has_threat_to(other_body):
	for entity in entities:
		if entity.m.collector.can_collect(other_body):
			return true
	return false

func has_food_for(other_body):
	for entity in entities:
		if other_body.m.collector.can_collect(entity):
			return true
	return false

func inform_all_of_type_change():
	for entity in entities:
		entity.m.silkreader.update_silk_type(body)

func has_strong_one():
	for entity in entities:
		if entity.m.specialties.check_type("strong"):
			return true
	
	return false

func unstuck_players():
	for entity in entities:
		if not entity.m.status.is_player(): continue
		if not entity.m.status.is_incapacitated: continue
		entity.m.status.capacitate()
