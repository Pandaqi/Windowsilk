extends Node2D

const DOUBLE_INTERVAL = { 'min': 8.0, 'max': 15.0 }

onready var timer = $Timer
onready var specialty_module = get_parent().get_parent()
onready var body = specialty_module.get_parent()
onready var entities = get_node("/root/Main/Entities")

func activate():
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
