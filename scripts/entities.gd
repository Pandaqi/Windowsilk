extends Node2D

# DEBUGGING
#good values are 3-8, setting to 1 is just for testing
const BOUNDS = { 'min': 1, 'max': 1 }
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
	available_types.erase("player_spider")

	precalculate_probabilities()
	_on_Timer_timeout()

# This gives all entities a certain probabililty (based on their point value + some optional extra data)
# And saves that in a way that is very easy/cheap to calculate at runtime
func precalculate_probabilities():
	var e = GlobalDict.entities
	var sum : float = 0.0
	for key in available_types:
		var data = e[key]
		
		# basic weight is inverse of point total => entities worth more points are less likely to appear
		var weight = 1.0 / float(max(data.points, 1.0))
		
		# but this can be scaled with an optional "prob" parameter
		if data.has('scale_prob'):
			weight *= data.scale_prob
		
		data.prob = weight
		sum += weight
	
	var running_sum : float = 0.0
	for key in available_types:
		running_sum += (e[key].prob / sum)
		e[key].weight = running_sum

func get_random_type():
	if available_types.size() <= 0: return null 
	
	var target = randf()
	for key in available_types:
		if GlobalDict.entities[key].weight >= target:
			return key

func _on_Timer_timeout():
	check_placement()
	restart_timer()

func restart_timer():
	timer.wait_time = rand_range(TIME_BOUNDS.min, TIME_BOUNDS.max)
	timer.start()

func check_placement():
	var num_entities = get_tree().get_nodes_in_group("NonPlayers").size()
	if num_entities >= BOUNDS.max: return
	
	place_entity()
	num_entities += 1
	
	while num_entities < BOUNDS.min:
		place_entity()
		num_entities += 1

func place_entity():
	var entity = entity_scene.instance()

	var rand_type = get_random_type()
	add_child(entity)
	
	print("PLACED TYPE")
	print(rand_type)
	
	entity.m.status.set_type(rand_type)
	entity.m.status.make_non_player()
	entity.m.status.initialize(placement_params)
