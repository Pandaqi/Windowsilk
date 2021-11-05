extends Node2D

onready var body = get_parent()
onready var col_shape_node = $Area2D/CollisionShape2D
var col_shape

func _ready():
	col_shape = col_shape_node.shape
	col_shape = col_shape.duplicate(true)
	col_shape_node.shape = col_shape

# NOTE: Although sprites are 256x256, bugs are horizontal and (on the Y-axis) only take up something near 128
# The other values are the sprite downward scale, and 0.5 because it's a RADIUS (not DIAMETER)
func update_collision_shape(new_scale):
	col_shape.radius = 128*0.33*0.5*new_scale

func collect(node):
	handle_collectible_type(node.m.status.type)
	handle_points(node)
	node.m.status.die()

func handle_points(node):
	body.m.points.change(node.m.points.count())

func handle_collectible_type(tp):
	pass

func _on_Area2D_body_entered(other_body):
	if not can_collect(other_body): return
	
	collect(other_body)

func can_collect(other_body):
	if other_body == body: return false
	if not other_body.is_in_group("Entities"): return false
	if other_body.m.status.is_dead: return false
	if other_body.m.points.count() >= body.m.points.count(): return false
	return true
