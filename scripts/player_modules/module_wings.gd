extends Node2D

const COLLAPSE_DUR : float = 0.5
const FLAP_DUR : float = 0.2
const WING_FLAP_SCALE : float = 0.5

onready var tween = $Tween
var planned_animation = null

var active : bool = false
var data

var wingL
var wingR

func disable():
	set_visible(false)
	active = false

# TO DO: This is just the same as disable() ... but not sure if it SHOULD be that way
func incapacitate():
	set_visible(false)
	active = false

func initialize(new_data):
	data = new_data
	
	if not data.has('min_rot'):
		data.min_rot = 0.1*PI
	if not data.has('max_rot'):
		data.max_rot = 0.35*PI
	
	show_behind_parent = true
	if data.has('show_in_front'):
		show_behind_parent = false
	
	create_both_wings()
	
	active = true
	set_visible(true)

func create_both_wings():
	var scene = load("res://scenes/wings/" + data.type + ".tscn").instance()
	
	wingL = scene.get_node("L")
	wingL.get_parent().remove_child(wingL)
	
	wingR = wingL.duplicate(true)
	wingR.position.y *= -1
	wingR.get_node("Sprite").flip_v = true
	
	add_child(wingL)
	add_child(wingR)

func on_move_type_changed(new_type):
	if not active: return
	
	if new_type == "web":
		play_wing_collapse()
	else:
		play_wing_unfold()

func play_wing_collapse():
	if data.has('collapse_using_scale'):
		var end_scale = Vector2(1, WING_FLAP_SCALE)
		if data.has('flap_scale'): end_scale.y = data.flap_scale
		
		tween.interpolate_property(self, "scale",
		Vector2(1,1), end_scale, COLLAPSE_DUR,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	else:
		tween.interpolate_property(wingL, "rotation",
			data.max_rot, data.min_rot, COLLAPSE_DUR,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
		tween.interpolate_property(wingR, "rotation",
			-data.max_rot, -data.min_rot, COLLAPSE_DUR,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.start()
	
	planned_animation = null

func play_wing_unfold():
	if data.has('collapse_using_scale'):
		tween.interpolate_property(self, "scale",
		get_scale(), Vector2(1,1), COLLAPSE_DUR,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	else:
		tween.interpolate_property(wingL, "rotation",
			data.min_rot, data.max_rot, COLLAPSE_DUR,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
		tween.interpolate_property(wingR, "rotation",
			-data.min_rot, -data.max_rot, COLLAPSE_DUR,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.start()
	
	planned_animation = "WingFlap"

func play_wing_flap():
	var start_scale = Vector2(1,1)
	var end_scale = Vector2(1, WING_FLAP_SCALE)
	if data.has('flap_scale'): end_scale.y = data.flap_scale
	
	var dur = FLAP_DUR
	if data.has('flap_dur'): dur = data.flap_dur
	
	wingL.set_rotation(data.max_rot)
	wingR.set_rotation(-data.max_rot)
	
	tween.interpolate_property(self, "scale",
		start_scale, end_scale, dur, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "scale",
		end_scale, start_scale, dur, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT,
		dur)
	
	tween.start()
	
	planned_animation = "WingFlap"

func _on_Tween_tween_all_completed():
	if not planned_animation: return
	
	var anim_key = planned_animation
	planned_animation = null

	if anim_key == "WingFlap":
		play_wing_flap()
