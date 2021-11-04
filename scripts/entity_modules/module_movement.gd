extends Node2D

var vec : Vector2

signal move_vec(vec, dt)

func _physics_process(dt):
	emit_signal("move_vec", vec, dt)

func pick_new_vec():
	var rot = 2*PI*randf()
	vec = Vector2(cos(rot), sin(rot))

func _on_WebTracker_arrived_on_edge(e):
	var already_has_chosen_dir = vec.length() >= 0.03
	if already_has_chosen_dir: return
	pick_new_vec()

func _on_WebTracker_arrived_on_point(p):
	pick_new_vec()
