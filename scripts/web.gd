extends Node2D

onready var edges = $Edges
onready var points = $Points

onready var main_node = get_node("/root/Main")

const EDGE_MARGIN : float = 50.0
const BOUND_THICKNESS : float = 64.0

var vp = Vector2(1920, 1080)
var corners = [
	Vector2.ZERO,
	Vector2(1920, 0),
	Vector2(1920, 1080),
	Vector2(0, 1080)
]

func activate():
	inset_corners()
	position_bounds()
	load_default_web()

func inset_corners():
	corners[0] += Vector2(1,1)*EDGE_MARGIN
	corners[1] += Vector2(-1,1)*EDGE_MARGIN
	corners[2] += Vector2(-1,-1)*EDGE_MARGIN
	corners[3] += Vector2(1,-1)*EDGE_MARGIN

func position_bounds():
	$Bounds/Right.position.x = corners[1].x + BOUND_THICKNESS
	$Bounds/Down.position.y = corners[2].y + BOUND_THICKNESS
	$Bounds/Left.position.x = corners[0].x - BOUND_THICKNESS
	$Bounds/Up.position.y = corners[0].y - BOUND_THICKNESS

func load_default_web():
	yield(get_tree(), "idle_frame")
	
	var res = edges.shoot(corners[0], corners[2] - corners[0])
	
	get_node("/root/Main/Players/Player/WebTracker").arrived_on_edge(res.new_edge)
	
	yield(get_tree(), "idle_frame")
	
	edges.shoot(corners[1], corners[3] - corners[1])
	
	yield(get_tree(), "idle_frame")
	
	edges.shoot(0.5*vp, corners[3] - corners[1])
	
	main_node.web_loading_done()
