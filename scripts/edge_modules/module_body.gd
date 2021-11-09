extends Node2D

const MIN_LENGTH_FOR_POINT_MOVING : float = 100.0

var thickness : float = GlobalDict.cfg.line_thickness

var start
var end

onready var body = get_parent()
onready var col_node = get_node("../CollisionShape2D")
onready var edges = get_node("/root/Main/Web/Edges")
var col_shape

func _ready():
	initialize_col_shape()

func initialize_col_shape():
	col_shape = RectangleShape2D.new()
	col_node.shape = col_shape

func set_extremes(s,e):
	set_start(s)
	set_end(e)

func move_extremes_inward(speed, dt):
	if get_length() <= MIN_LENGTH_FOR_POINT_MOVING: return
	
	var vel = get_vec() * speed
	start.m.body.move(vel, dt)
	end.m.body.move(-vel, dt)

func set_start(s):
	start = s
	on_change()

func set_end(e):
	end = e 
	on_change()

func get_thickness():
	return thickness

func get_center():
	return 0.5*(start.position + end.position)

func get_vec():
	return (end.position - start.position)

func get_length():
	return get_vec().length()

func get_vec_norm():
	return get_vec().normalized()

func get_vec_starting_from(node):
	if node == start: return get_vec()
	else: return -get_vec()

func on_change():
	if (not start) or (not end): return
	
	body.m.status.check()

# NOTE: default rotation is RIGHT, so X is the distance between points, Y is the thickness
func update_body():
	var half_length = 0.5*get_length()
	var half_width = 0.5*thickness
	
	var rot = get_vec().normalized().angle()
	body.set_rotation(rot)
	body.set_position(get_center())
	
	col_shape.extents = Vector2(half_length, half_width)

func get_closest_point(e):
	var distA = (start.position - e.position).length()
	var distB = (end.position - e.position).length()
	if distA < distB: return start
	return end

func get_dist_to_closest_point(e):
	var distA = (start.position - e.position).length()
	var distB = (end.position - e.position).length()
	return min(distA, distB)

func get_random_pos_on_me(margin = 0.0):
	var vec = get_vec()
	var rand = (randf()*(1.0-2*margin)) + margin
	return start.position + rand*vec

# Is point C between points A and B (line segment)?
# A higher epsilon means less floating point precision errors ... but the algorithm might also be plain wrong (from time to time) if the value is too high
func point_is_between(a, b, c, epsilon):
	var crossproduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y)
	if abs(crossproduct) > epsilon: return false
	
	var dotproduct = (c.x - a.x) * (b.x - a.x) + (c.y - a.y)*(b.y - a.y)
	if dotproduct < 0: return false
	
	var squaredlengthba = (b - a).length_squared()
	if dotproduct > squaredlengthba:
		return false
	
	return true

func self_destruct():
	edges.remove_existing(body)
