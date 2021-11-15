extends Node2D

onready var body = get_parent()
onready var timer = $Timer

var is_dead : bool = false
var is_incapacitated : bool = true

func initialize(rot_time):
	body.m.points.set_to(0)
	
	body.m.sprite.set_frame(randi() % 4)
	
	timer.wait_time = rot_time
	timer.start()

func die():
	body.queue_free()

func _on_Timer_timeout():
	body.m.points.change(-1)

func is_player():
	return false
