extends Node2D

const DOUBLE_INTERVAL = { 'min': 12.0, 'max': 20.0 }

onready var timer = $Timer
onready var specialty_module = get_parent().get_parent()
onready var body = specialty_module.get_parent()
var entities

func activate():
	entities = get_node("/root/Main/Entities")
	restart_timer()

func deactivate():
	timer.stop()

func restart_timer():
	timer.wait_time = rand_range(DOUBLE_INTERVAL.min, DOUBLE_INTERVAL.max)
	timer.start()

func _on_Timer_timeout():
	make_double()
	restart_timer()

func make_double():
	var params = {
		'type': body.m.status.type,
		'fixed_pos': body.position,
		'fixed_edge': body.m.tracker.get_current_edge(),
		'fixed_point': body.m.tracker.get_current_point()
	}
	
	entities.place_entity(params)
