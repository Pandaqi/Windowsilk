extends Node2D

onready var body = get_parent()
onready var col_shape_node = $Area2D/CollisionShape2D
var col_shape

var data

func _ready():
	col_shape = col_shape_node.shape
	col_shape = col_shape.duplicate(true)
	col_shape_node.shape = col_shape

func set_data(new_data):
	if not new_data.has('collect'):
		data = {}
	else:
		data = new_data.collect

# NOTE: Although sprites are 256x256, bugs are horizontal and (on the Y-axis) only take up something near 128
# The other values are the sprite downward scale, and 0.5 because it's a RADIUS (not DIAMETER)
func update_collision_shape(new_scale):
	col_shape.radius = 128*0.33*0.5*new_scale

func collect(node):
	if body.m.status.is_player():
		var specialty = node.m.specialties.get_it()
		body.m.specialties.set_to(specialty)
	
	handle_points(node)
	node.m.status.die()

func handle_points(node):
	var original_points = node.m.points.count()
	var actual_points = body.m.specialties.modify_points(original_points)
	body.m.points.change(actual_points)

func _on_Area2D_body_entered(other_body):
	if not can_collect(other_body): return
	
	collect(other_body)

func is_friendly():
	if not data.has('friendly'): return false
	return data.friendly

func is_cannibal():
	if GlobalDict.cfg.allow_eating_same_species: return true
	if not data.has('cannibal'): return false
	return data.cannibal

func can_always_be_eaten():
	if not data.has('always'): return false
	return data.always

func can_collect(other_body):
	# cannot eat ourselves or non-entities
	if other_body == body: return false
	if not other_body.is_in_group("Entities"): return false
	
	# if the other is no (longer) a valid entity, abort
	if other_body.m.status.is_dead: return false

	# special properties that mess with eating
	if not data.has('ignore_specialties'):
		if is_friendly(): return false
		
		if body.m.specialties.can_eat_anything(): return true
		if other_body.m.collector.can_always_be_eaten(): return true
		
		if not other_body.m.specialties.can_be_eaten(): return false
		if body.m.status.same_type_as_node(other_body) and not is_cannibal(): return false
	
	# now apply the point check => more points than the other? can eat
	var margin = 0
	var apply_point_difference_check = body.is_in_group("Players") or GlobalDict.cfg.point_difference_holds_for_all
	
	if other_body.is_in_group("Players") and apply_point_difference_check: 
		margin = GlobalDict.cfg.point_difference_eating_players
	
	var we_have_more_points = (body.m.points.count() > (other_body.m.points.count() + margin))
	if not we_have_more_points: return false
	return true
