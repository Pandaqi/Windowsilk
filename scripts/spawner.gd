extends Node2D

const BOUNDS = { 'min': 3, 'max': 8 }
const TIME_BOUNDS = { 'min': 3.0, 'max': 7.0 }

const OFFSET_FROM_EDGE : Dictionary = { 'min': 50.0, 'max': 150.0 }

var item_scene = preload("res://scenes/item.tscn")

var available_types = ['silk']
var place_on_web : bool = true

onready var timer = $Timer

func activate():
	_on_Timer_timeout()

func _on_Timer_timeout():
	check_placement()
	restart_timer()

func restart_timer():
	timer.wait_time = rand_range(TIME_BOUNDS.min, TIME_BOUNDS.max)
	timer.start()

func check_placement():
	var num_items = get_tree().get_nodes_in_group("Items").size()
	if num_items >= BOUNDS.max: return
	
	place_item()
	num_items += 1
	
	while num_items < BOUNDS.min:
		place_item()
		num_items += 1

func get_random_type():
	return available_types[randi() % available_types.size()]

func get_random_position():
	var edges = get_tree().get_nodes_in_group("Edges")
	var rand_edge = edges[randi() % edges.size()]
	
	var vec = rand_edge.get_vec()
	var vec_norm = vec.normalized()
	var rand_pos = rand_edge.start.position + randf()*vec
	
	if place_on_web: return rand_pos
	
	var ortho_vec = vec_norm.rotated(0.5*PI)
	if randf() <= 0.5: ortho_vec = vec_norm.rotated(-0.5*PI)
	
	rand_pos += ortho_vec*rand_range(OFFSET_FROM_EDGE.min, OFFSET_FROM_EDGE.max)
	return rand_pos

func place_item():
	var item = item_scene.instance()
	item.set_position(get_random_position())
	item.set_type(get_random_type())
	add_child(item)
	
	place_on_web = not place_on_web
	
	print("ITEM PLACED")
	print(item.position)
