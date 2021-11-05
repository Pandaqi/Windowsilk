extends Node2D

const PAUSE_TIME : float = 4.0

var val : float = 0.0
var reset_val : float = -1

onready var movement_handler = get_parent()
onready var body = movement_handler.get_parent()

onready var timer = $Timer

func activate(initial_value):
	reset_val = initial_value
	reset()

func reset():
	val = reset_val

func subtract(ds):
	if reset_val <= 0: return
	
	val -= ds
	
	if val <= 0.0:
		pause()
		reset()

func _on_Mover_on_move_completed(vec):
	subtract(vec.length())

func pause():
	body.m.mover.disable()
	
	timer.wait_time = PAUSE_TIME
	timer.start()

func unpause():
	body.m.mover.enable()

func _on_Timer_timeout():
	unpause()
