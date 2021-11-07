extends Node2D

var entities = []

var entities_passed = 0
var TIMEBOMB_BOUNDS = { 'min': 1, 'max': 7 }
var rand_entity_threshold : int = 0

onready var body = get_parent()

func _ready():
	rand_entity_threshold = round(rand_range(TIMEBOMB_BOUNDS.min, TIMEBOMB_BOUNDS.max))

func add(e):
	entities.append(e)
	entities_passed += 1
	
	if body.m.type.equals("timebomb") and entities_passed > rand_entity_threshold:
		body.m.body.self_destruct()

func remove(e):
	print("WANT TO REMOVE ENTITY FROM EDGE")
	if not e in entities:
		print("... BUT THEY DON'T EXIST")
	
	entities.erase(e)
	
	if body.m.type.equals("fragile") and entities_passed > 0:
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
