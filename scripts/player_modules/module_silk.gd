extends Node2D

var MAX_POINTS : int = 9

var num : int = 0

onready var label_container = $LabelContainer
onready var label = $LabelContainer/Label

onready var body = get_parent()
onready var main_node = get_node("/root/Main")

signal point_change(val)

func _ready():
	MAX_POINTS = GlobalDict.cfg.max_points_capacity

func set_to(val):
	change(val - num)

func change(val):
	num = clamp(num + val, 0.0, MAX_POINTS)
	
	label.set_text(str(num))
	body.m.visuals.update_scale(num)
	body.m.mover.update_speed_scale(num)
	
	if not GlobalDict.cfg.objective_uses_home_base:
		main_node.on_player_progression(body)

func _physics_process(_dt):
	label_container.set_rotation(-body.rotation)

func empty():
	change(-num)

func is_empty():
	return (num <= 0)
	
func at_max_capacity():
	return (num >= MAX_POINTS)

func count():
	return num

