extends Node2D

onready var col_node = get_node("../CollisionShape2D")
onready var body = get_parent()

var col_shape
var scale_factor : float = 1.0
var fixed : bool = false

func update_body():
	col_node.shape = col_node.shape.duplicate(true)
	
	col_shape = col_node.shape
	col_shape.radius = GlobalDict.cfg.line_thickness * scale_factor

func scale_collision_shape(f):
	scale_factor = f
	update_body()

func move(vec, _dt):
	if fixed: return
	
	body.move_and_slide(vec)
	body.m.entities.inform_future()
	body.m.status.check()

func get_radius():
	return col_shape.radius / scale_factor

func make_fixed():
	if fixed: return
	
	fixed = true
	scale_collision_shape(2.0)
	body.m.drawer.scale_radius(2.0)

func is_fixed():
	return fixed
