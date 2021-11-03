extends Node2D

onready var body = get_parent()

func collect(node):
	handle_collectible_type(node.type)
	node.queue_free()

func handle_collectible_type(tp):
	match tp:
		'silk':
			body.m.silk.change(+1)
