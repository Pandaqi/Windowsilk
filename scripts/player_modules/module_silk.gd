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
	var no_lives_left = (num == 0)
	if no_lives_left and val < 0:
		body.m.status.die()
		return
	
	num = clamp(num + val, 0.0, MAX_POINTS)
	
	label.set_text(str(num))
	body.m.visuals.update_scale(num)
	body.m.mover.update_speed_scale(num)
	
	if not GlobalDict.cfg.objective_uses_home_base:
		main_node.on_player_progression(body)
	
	body.m.tween.interpolate_property(label_container, "scale",
		Vector2(2,2), Vector2(1,1), 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	body.m.tween.start()

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

func is_small():
	return num <= GlobalDict.cfg.point_reset_val

func change_icon_visibility(val):
	label.set_visible(val)

func _on_GeneralArea_on_nearby_players_changed(val):
	change_icon_visibility(val)
