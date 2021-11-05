extends Node2D

const TIMER_BOUNDS = { 'min': 0.75, 'max': 2.5 }

onready var movement_handler = get_parent()
onready var timer = $Timer

func activate():
	_on_Timer_timeout()

func _on_Timer_timeout():
	restart_timer()
	movement_handler.active_module.pick_opposite_vec()

func restart_timer():
	timer.stop()
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()
