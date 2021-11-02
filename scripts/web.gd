extends Node2D

onready var edges = $Edges
onready var points = $Points

var vp = Vector2(1920, 1080)
var corners = [
	Vector2.ZERO,
	Vector2(1920, 0),
	Vector2(1920, 1080),
	Vector2(0, 1080)
]

func activate():
	load_default_web()

func load_default_web():
	var res = edges.shoot(corners[0], corners[2] - corners[0])
	
	get_node("/root/Main/Players/Player/WebTracker").arrived_on_edge(res.new_edge)
	
	yield(get_tree(), "idle_frame")
	
	edges.shoot(corners[1], corners[3] - corners[1])
	
	yield(get_tree(), "idle_frame")
	
	edges.shoot(0.5*vp, corners[3] - corners[1])
