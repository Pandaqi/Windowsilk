extends Node2D

onready var col_node = get_node("../CollisionShape2D")
onready var body = get_parent()

var col_shape
var scale_factor : float = 1.0

func update_body():
	col_node.shape = col_node.shape.duplicate(true)
	
	col_shape = col_node.shape
	col_shape.radius = GlobalDict.cfg.line_thickness * scale_factor

func scale_collision_shape(f):
	scale_factor = f
	update_body()

func move(vec, _dt):
	body.move_and_slide(vec)
	
	body.m.status.check()

func get_radius():
	return col_shape.radius / scale_factor
