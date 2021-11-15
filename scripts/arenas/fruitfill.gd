extends Node2D

const TIMER_BOUNDS = { 'min': 5, 'max': 10 }
const COLLECTIBLE_BOUNDS = { 'min': 2, 'max': 5 }
const OFF_WEB_PROB : float = 0.1
const ROTTING_INTERVAL : float = 10.0

onready var timer = $Timer
onready var spawner = get_node("/root/Main/Spawner")
onready var web = get_node("/root/Main/Web")

var fruit_scene = preload("res://scenes/arenas/fruit.tscn")

func activate():
	_on_Timer_timeout()

func _on_Timer_timeout():
	check_fruit()
	restart_timer()

func restart_timer():
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func check_fruit():
	var num_fruit = get_tree().get_nodes_in_group("Collectibles").size()
	if num_fruit >= COLLECTIBLE_BOUNDS.max: return
	
	place_fruit()
	num_fruit += 1
	
	while num_fruit < COLLECTIBLE_BOUNDS.min:
		place_fruit()
		num_fruit += 1

func place_fruit():
	var params = {
		'avoid_players': true,
		'avoid_entities': true,
		'avoid_web': (randf() <= OFF_WEB_PROB)
	}
	
	var data = spawner.get_valid_random_position(params)
	
	var f = fruit_scene.instance()
	f.set_position(data.pos)
	web.entities.add_child(f)
	
	f.m.status.initialize(ROTTING_INTERVAL)
	
	print("FRUIT PLACED AT")
	print(data.pos)
