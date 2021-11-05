extends Node2D

const TIME_BOUNDS = { 'min': 3, 'max': 5 }

onready var timer = $Timer

signal on_instant_jump(params)

func activate():
	_on_Timer_timeout()

func _on_Timer_timeout():
	restart_timer()
	jump()

func restart_timer():
	timer.wait_time = rand_range(TIME_BOUNDS.min, TIME_BOUNDS.max)
	timer.start()

func jump():
	var params = {
		'dont_create_new_edges': true,
		'find_valid_dir': true
	}
	emit_signal("on_instant_jump", params)
