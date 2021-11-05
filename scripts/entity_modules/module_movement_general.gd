extends "res://scripts/module_selector.gd"

const ENTITY_RAYCAST_DIST = 150
const WEB_RAYCAST_DIST = 50

var data
onready var entity_rc = $EntityRaycast
onready var web_rc = $WebRaycast

func initialize():
	if not active_module: return
	active_module.initialize()

func set_data(new_data):
	if not new_data.has('move'):
		data = {}
	else:
		data = new_data.move

func _on_Tracker_arrived_on_edge(e):
	if not active: return
	if not active_module.has_method("_on_Tracker_arrived_on_edge"): return
	active_module._on_Tracker_arrived_on_edge(e)

func _on_Tracker_arrived_on_point(p):
	if not active: return
	if not active_module.has_method("_on_Tracker_arrived_on_point"): return
	active_module._on_Tracker_arrived_on_point(p)

func _physics_process(dt):
	._physics_process(dt)
	
	check_raycast()
	
	if active_module.has_method("custom_check_raycast"):
		active_module.custom_check_raycast(entity_rc, web_rc)

func check_raycast():
	entity_rc.cast_to = Vector2.RIGHT * ENTITY_RAYCAST_DIST
	web_rc.cast_to = Vector2.RIGHT * WEB_RAYCAST_DIST

	check_flee_and_chase()

func check_flee_and_chase():
	if not entity_rc.get_collider(): return
	
	var hit_body = entity_rc.get_collider()
	if not hit_body.is_in_group("Entities"): return
	
	var body_is_a_threat = hit_body.m.collector.can_collect(body)
	var body_is_food = body.m.collector.can_collect(hit_body)
	
	if has_fleeing_behavior(hit_body) and body_is_a_threat:
		var vec_away = (body.position - hit_body.position).normalized()
		active_module.set_vector(vec_away)
	
	if has_chasing_behavior(hit_body) and not body_is_food:
		var vec_to = (hit_body.position - body.position).normalized()
		active_module.set_vector(vec_to)

func has_fleeing_behavior(other_body):
	if not data.has('flee'): return false
	if data.has('flee_type') and not other_body.m.status.same_type(data.flee_type): return false
	return data.flee

func has_chasing_behavior(other_body):
	if not data.has('chase'): return false
	if data.has('chase_type') and not other_body.m.status.same_type(data.chase_type): return false
	return data.chase
