extends Node2D

onready var body = get_parent()

func collect(node):
	handle_collectible_type(node.m.status.type)
	handle_points(node)
	node.m.status.die()

func handle_points(node):
	body.m.points.collect(node.m.points.count())

func handle_collectible_type(tp):
	match tp:
		'tiny_spider':
			body.m.silk.change(+1)

func _on_Area2D_body_entered(body):
	if not can_collect(body): return
	
	collect(body)

func can_collect(body):
	if body.is_in_group("Players"): return false
	if body.is_in_group("Entities"): return true
	return false
