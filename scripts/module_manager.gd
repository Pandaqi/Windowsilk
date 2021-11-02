extends KinematicBody2D

var m = {}

func _ready():
	for child in get_children():
		var key = child.name.to_lower()
		m[key] = child
