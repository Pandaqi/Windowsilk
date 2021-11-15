extends Node2D

onready var body = get_parent()
onready var col_shape_node = $Area2D/CollisionShape2D
var col_shape

var data
var active : bool = true

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
	
	# if we eat something while having the poison powerup
	# we don't kill it, we just poison it
	var should_die = true
	if node.m.has('specialties'):
		if body.m.specialties.check_type("poison"):
			node.m.specialties.set_to("poison")
			should_die = false
		
		if body.m.status.is_player():
			var specialty = node.m.specialties.get_it()
			body.m.specialties.set_to(specialty)

	if should_die:
		handle_points(node)
		node.m.status.die()

func handle_points(node):
	var original_points = node.m.points.count()
	var actual_points = body.m.specialties.modify_points(original_points)
	body.m.points.change(actual_points)

func _on_Area2D_body_entered(other_body):
	if not active: return
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

func can_collect(other_body, give_feedback = true):
	# collectibles are like a subset of "static entities" 
	# that can always be eaten and don't need all these checks
	# (prime example: Fruit)
	if other_body.is_in_group("Collectibles"):
		return true
	
	# cannot eat ourselves or non-entities
	if other_body == body: return false
	if not other_body.is_in_group("Entities"): return false
	
	# we're at max capacity?
	if body.m.points.at_max_capacity(): 
		if give_feedback: body.m.status.give_constant_feedback("Max capacity!")
		return false
	
	# if the other is no (longer) a valid entity, abort
	if other_body.m.status.is_dead: return false
	
	# conversely, if the other is incapacitated, they cannot defend themselves and eating is always possible
	# (mostly applies to flying bugs getting stuck in player-owned silk)
	if other_body.m.status.is_incapacitated: return true
	
	# if a player is near their home base, they are invincible
	if other_body.m.generalarea.has_protection_from_home_base(): 
		if give_feedback: other_body.m.status.give_constant_feedback("Protected by home!")
		return false
	
	# no need to eat/chase something that's already poisoned if we're poisoned
	if body.m.specialties.is_poisoned() and other_body.m.specialties.is_poisoned():
		return false

	# special properties that mess with eating
	if not data.has('ignore_specialties'):
		if is_friendly(): return false
		
		if body.m.specialties.can_eat_anything(): 
			if give_feedback: body.m.status.give_constant_feedback("Hungry!")
			return true
		if other_body.m.collector.can_always_be_eaten(): return true
		
		if not other_body.m.specialties.can_be_eaten(): 
			if give_feedback: body.m.status.give_constant_feedback("Can't be eaten!")
			return false
		if body.m.status.same_type_as_node(other_body) and not is_cannibal(): return false
	
	# now apply the point check => more points than the other? can eat
	var margin = 0
	var we_are_player = body.is_in_group("Players")
	var they_are_player = other_body.is_in_group("Players")
	var apply_point_difference_check = body.is_in_group("Players") or GlobalDict.cfg.point_difference_holds_for_all
	
	if they_are_player and apply_point_difference_check: 
		margin = GlobalDict.cfg.point_difference_eating_players
	
	var our_points = body.m.points.count()
	var their_points = other_body.m.points.count()
	
	if we_are_player and they_are_player:
		if not GlobalDict.cfg.allow_eating_small_players and other_body.m.points.is_small():
			if give_feedback: body.m.status.give_constant_feedback("Too small to eat!")
			return false
	
	var we_have_more_points = (our_points > (their_points + margin))
	if not we_have_more_points: return false
	return true

func disable():
	active = false

func enable():
	active = true

func _on_Status_on_death():
	disable()

func _on_Respawner_on_revive():
	enable()
