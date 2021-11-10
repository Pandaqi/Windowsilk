extends Node2D

var POINT_REDUCTION_TIMER : float = 5.0

onready var timer = $Timer
onready var specialty_module = get_parent().get_parent()
onready var body = specialty_module.get_parent()

const SPEED_DECREASE_PER_TIMEOUT : float = 0.1
var speed_multiplier : float = 1.0

func activate():
	speed_multiplier = 1.0 
	restart_timer()

func deactivate():
	timer.stop()

func restart_timer():
	speed_multiplier = max(speed_multiplier - SPEED_DECREASE_PER_TIMEOUT, 0.2)
	
	timer.wait_time = POINT_REDUCTION_TIMER
	timer.start()

func _on_Timer_timeout():
	var no_lives_left = (body.m.points.count() <= 0)
	if no_lives_left:
		body.m.status.die()
		return
	
	body.m.points.change(-1)

func get_speed_multiplier():
	return speed_multiplier
