extends Node2D

var m = {}

func _ready():
	for child in get_children():
		var key = child.name.to_lower()
		add_module(key, child)

func add_module(key, node):
	m[key] = node

func has_module(key):
	return m.has(key)

func erase_module(key):
	m[key].queue_free()
	m.erase(key)
