extends Node2D

const TIMER_BOUNDS = { 'min': 3, 'max': 8 }
onready var timer = $Timer

signal on_instant_jump(params)

func activate():
	restart_timer()

func restart_timer():
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func _on_Timer_timeout():
	restart_timer()
	fake_jump()

func fake_jump():
	emit_signal("on_instant_jump", {})
