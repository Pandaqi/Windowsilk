extends Node2D

# NOTE: These values are GLOBAL positions
# The starts are actual NODES, so they automatically rotate and move correctly with the object
onready var legs = {
	'L1': { 'start': $L1, 'end': Vector2.ZERO },
	'L2': { 'start': $L2, 'end': Vector2.ZERO },
	'L3': { 'start': $L3, 'end': Vector2.ZERO },
	'L4': { 'start': $L4, 'end': Vector2.ZERO },
	
	'R1': { 'start': $R1, 'end': Vector2.ZERO },
	'R2': { 'start': $R2, 'end': Vector2.ZERO },
	'R3': { 'start': $R3, 'end': Vector2.ZERO },
	'R4': { 'start': $R4, 'end': Vector2.ZERO },
}

var leg_color = Color(121/255.0, 55/255.0, 0)

onready var visuals = get_parent()
onready var body = visuals.get_parent()

func _ready():
	reset_legs()

func reset_legs():
	for key in legs:
		reset_leg(legs[key])

func calculate_leg_dist(leg):
	var desired_pos = get_desired_leg_pos(leg)
	return (leg.end - desired_pos).length()

func get_desired_leg_pos(leg):
	return leg.start.get_node("Offset").global_position

func reset_leg(leg):
	leg.end = get_desired_leg_pos(leg)

func _physics_process(dt):
	check_legs()
	update()

func check_legs():
	var dist_left = 0
	var dist_right = 0
	
	var threshold = 30
	for key in legs:
		var leg = legs[key]
		threshold = 30 + (randf()-0.5)*4
		var dist = calculate_leg_dist(leg)
		
		var sibling = "L" + key.right(1)
		if key.left(1) == "L":
			dist_left += dist
			sibling = "R" + key.right(1)
		else:
			dist_right += dist
		
		sibling = legs[sibling]
		
		var sibling_dist = calculate_leg_dist(sibling)
		if dist > threshold and sibling_dist > 0.5*threshold:
			reset_leg(leg)
	
	# wiggle based on which legs are furthest behind
	var sprite = body.m.visuals.get_node("Sprite")
	var target_rotation = 0.02*PI
	if dist_left > dist_right:
		target_rotation *= -1
	sprite.set_rotation(lerp(sprite.get_rotation(), target_rotation, 0.1))

func _draw():
	for key in legs:
		draw_leg(legs[key])

func draw_leg(leg):
	var start = leg.start.position
	var end = to_local(leg.end)
	
	var orthogonal = Vector2.DOWN
	if start.y < 0: orthogonal = Vector2.UP
	
	#orthogonal = orthogonal.rotated(body.rotation)
	
	var middle = 0.5*(start + end) + orthogonal * 5
	
	draw_polyline([start, middle, end], leg_color, 4)
