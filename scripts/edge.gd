extends StaticBody2D

const THICKNESS : float = 10.0
const COLOR : Color = Color(1,1,1)

var start
var end

var entities = []

onready var col_node = $CollisionShape2D
var col_shape

func _ready():
	initialize_col_shape()

func initialize_col_shape():
	col_shape = RectangleShape2D.new()
	col_node.shape = col_shape

#
# Endpoint management
# (turn all these comments + code into separate modules)
#
func set_extremes(s,e):
	set_start(s)
	set_end(e)

func set_start(s):
	start = s
	on_change()

func set_end(e):
	end = e 
	on_change()

#
# Entity management
#
func add_entity(e):
	entities.append(e)
	update()

func remove_entity(e):
	entities.erase(e)
	update()

func get_entities_on_me():
	return entities

func try_adding_entities(entities):
	for e in entities:
		if not is_entity_on_me(e): continue
	
		e.m.webtracker.arrived_on_edge(self)
		
		print("SUCCESFULLY RE-ADDED ENTITIES")

func is_entity_on_me(e):
	return point_is_between(start.position, end.position, e.position)

func get_closest_point(e):
	var distA = (start.position - e.position).length()
	var distB = (end.position - e.position).length()
	if distA < distB: return start
	return end

# Is point C between points A and B (line segment)?
func point_is_between(a, b, c):
	var epsilon = 5.0
	
	var crossproduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y)
	if abs(crossproduct) > epsilon: return false
	
	var dotproduct = (c.x - a.x) * (b.x - a.x) + (c.y - a.y)*(b.y - a.y)
	if dotproduct < 0: return false
	
	var squaredlengthba = (b - a).length_squared()
	if dotproduct > squaredlengthba:
		return false
	
	return true

#
# Updating visuals and body
#
func get_center():
	return 0.5*(start.position + end.position)

func get_vec():
	return (end.position - start.position)

func get_vec_starting_from(node):
	if node == start: return get_vec()
	else: return -get_vec()

func on_change():
	if (not start) or (not end): return
	
	update_body()
	update_visuals()

# NOTE: default rotation is RIGHT, so X is the distance between points, Y is the thickness
func update_body():
	var half_length = 0.5*get_vec().length()
	var half_width = 0.5*THICKNESS
	
	col_shape.extents = Vector2(half_length, half_width)

func update_visuals():
	set_position(get_center())
	
	var rotation = get_vec().normalized().angle()
	set_rotation(rotation)
	
	update()

func _draw():
	var col_rect = col_shape.extents
	var rect = Rect2(-col_rect, 2*col_rect)
	
	var col = COLOR
	if entities.size() > 0: col = Color(1,0,0)
	
	draw_rect(rect, col, true)
