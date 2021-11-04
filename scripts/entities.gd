extends Node2D

const BOUNDS = { 'min': 3, 'max': 8 }
const TIME_BOUNDS = { 'min': 3.0, 'max': 7.0 }

var entity_scene = preload("res://scenes/entity.tscn")

var available_types = []

onready var spawner = get_node("../Spawner")
onready var timer = $Timer

var placement_params = {
	'small_radius': 30.0,
	'large_radius': 250.0,
	'avoid_entities': true,
	'avoid_players': true
}

func activate():
	available_types = GlobalDict.entities.keys()
	_on_Timer_timeout()

func _on_Timer_timeout():
	check_placement()
	restart_timer()

func restart_timer():
	timer.wait_time = rand_range(TIME_BOUNDS.min, TIME_BOUNDS.max)
	timer.start()

func check_placement():
	var num_entities = get_tree().get_nodes_in_group("Entities").size()
	if num_entities >= BOUNDS.max: return
	
	place_entity()
	num_entities += 1
	
	while num_entities < BOUNDS.min:
		place_entity()
		num_entities += 1

func get_random_type():
	return available_types[randi() % available_types.size()]

func place_entity():
	var entity = entity_scene.instance()

	var rand_type = get_random_type()
	add_child(entity)
	
	entity.m.status.set_type(rand_type)
	entity.m.status.initialize(placement_params)
