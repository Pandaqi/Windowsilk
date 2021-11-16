extends Node2D

var MAX_POINTS : int = 9
var MIN_POINTS : int = 0

const MIN_POINTS_COLLECTIBLE : int = -5
const MAX_POINTS_COLLECTIBLE : int = 0

var num : int = 0

onready var label_container = $LabelContainer
onready var label = $LabelContainer/Label

onready var body = get_parent()
onready var main_node = get_node("/root/Main")
onready var particles = get_node("/root/Main/Particles")

# warning-ignore:unused_signal
signal point_change(val)

func _ready():
	MAX_POINTS = GlobalDict.cfg.max_points_capacity

func set_to(val):
	change(val - num, false)

func collectible_change(val):
# warning-ignore:narrowing_conversion
	num = clamp(num + val, MIN_POINTS_COLLECTIBLE, MAX_POINTS_COLLECTIBLE)
	label.set_text(str(num))

func change(val, play_sound = true):
	
	if play_sound:
		var key = "receive_points"
		if val <= 0: key = "lose_points"
		body.m.status.play_sound(key)
	
	particles.create_point_particles(body.position)
	
	if body.is_in_group("Collectibles"):
		collectible_change(val)
		return
	
	var no_lives_left = (num == MIN_POINTS)
	if no_lives_left and val < 0:
		body.m.status.die()
		return
	
# warning-ignore:narrowing_conversion
	num = clamp(num + val, MIN_POINTS, MAX_POINTS)
	
	label.set_text(str(num))
	body.m.visuals.update_scale(num)
	body.m.mover.update_speed_scale(num)
	
	if not GlobalDict.cfg.objective_uses_home_base and body.m.status.is_player():
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
