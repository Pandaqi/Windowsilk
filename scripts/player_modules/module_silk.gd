extends Node2D

const MAX_POINTS : int = 100

var num : int = 0

onready var label_container = $LabelContainer
onready var label = $LabelContainer/Label

onready var body = get_parent()
onready var main_node = get_node("/root/Main")

signal point_change(val)

func set_to(val):
	change(val - num)

func change(val):
	num = clamp(num + val, 0.0, MAX_POINTS)
	
	label.set_text(str(num))
	body.m.visuals.update_scale(num)
	body.m.mover.update_speed_scale(num)
	
	main_node.on_player_progression(body)

func _physics_process(_dt):
	label_container.set_rotation(-body.rotation)

func is_empty():
	return (num <= 0)

func count():
	return num
