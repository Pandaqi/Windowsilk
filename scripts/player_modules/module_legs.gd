extends Node2D

# NOTE: These values are GLOBAL positions
# The starts are actual NODES, so they automatically rotate and move correctly with the object
onready var legs = {}

var leg_color = Color(121/255.0, 55/255.0, 0)
var leg_thickness = 4

onready var visuals = get_parent()
onready var body = visuals.get_parent()

func initialize(data):
	load_leg_data(data)

func load_leg_data(data):
	var scene = load("res://scenes/legs/" + data.type + '.tscn').instance()
	for child in scene.get_children():
		var key = child.name
		
		scene.remove_child(child)
		self.add_child(child)
		legs[key] = { 'start': child, 'end': Vector2.ZERO }
		
		if data.has('scale_offset'):
			child.position.y *= data.scale_offset
	
	if data.has('color') and (data.color is Color):
		leg_color = data.color
	
	if data.has('scale_thickness'):
		leg_thickness *= data.scale_thickness
	
	reset_legs()

func set_color(col):
	leg_color = col

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

func _physics_process(_dt):
	check_legs()
	set_rotation(-visuals.rotation)
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
	var target_rotation = 0.02*PI
	if dist_left > dist_right:
		target_rotation *= -1
	visuals.set_rotation(lerp(visuals.get_rotation(), target_rotation, 0.1))

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
	
	draw_polyline([start, middle, end], leg_color, leg_thickness)

func on_move_type_changed(new_type):
	set_visible(new_type == "web")
