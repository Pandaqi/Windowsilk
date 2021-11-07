extends Node2D

const DURATION : float = 8.0

var type : String = ""
onready var timer = $Timer

func set_to(tp):
	if (not tp) or (tp == ""): return
	
	type = tp
	
	handle_immediate_effect()
	restart_timer()
	show_icon()

func reset():
	type = ""
	hide_icon()

func get_it():
	return type

func show_icon():
	pass

func hide_icon():
	pass

func restart_timer():
	timer.wait_time = DURATION
	timer.start()

func _on_Timer_timeout():
	reset()

func handle_immediate_effect():
	if type == "": return

func handle_continuous_effect():
	if type == "": return

func _physics_process(dt):
	handle_continuous_effect()

func jumping_is_free():
	return type == "trampoline"

func erase_silk_types():
	return type == "eraser"

func modify_points(val):
	if type == "doubler": val *= 2
	elif type == "worthless": val = 0
	return val
