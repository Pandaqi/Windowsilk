extends Node2D

const SCALE_BOUNDS = { 'min': 0.65, 'max': 1.5 }
const SCALE_PER_POINT = 0.05

onready var sprite = $Sprite
onready var eyes = $Sprite/Eyes
onready var legs = $Legs
onready var antenna = $Antenna
onready var wings = $Wings
onready var worm = $Worm
onready var body = get_parent()

onready var stuck_lines = $StuckLines
onready var anim_player = $AnimationPlayer

onready var move_particles = $MoveParticles

var player_num : int = -1
var team_num : int = -1
var data = {}

func set_data(new_data):
	data = new_data
	
	sprite.set_frame(data.frame)
	
	if not data.has('visuals'): data.visuals = {}
	
	if data.has('legs'):
		legs.initialize(data.legs)
	
	if data.has('antenna'):
		antenna.initialize(data.antenna)
	
	if data.move.has('worm'):
		worm.initialize()
	
	if data.has('wings'):
		wings.initialize(data.wings)
	else:
		wings.disable()
	
	create_move_particles()

func incapacitate():
	wings.incapacitate()
	
	stuck_lines.set_visible(true)
	#stuck_lines.set_rotation(randf()*2*PI)
	
	var cur_edge = body.m.tracker.get_current_edge()
	if cur_edge:
		stuck_lines.modulate = cur_edge.m.drawer.get_color()
	
	anim_player.play("Stuck")

func capacitate():
	if body.m.status.is_flying_bug(): wings.capacitate()
	stuck_lines.set_visible(false)
	anim_player.stop(true)

func _on_Respawner_on_revive():
	stuck_lines.set_visible(false)
	sprite.set_scale(Vector2(1,1)*0.33)
	
	if anim_player.get_current_animation() == "Stuck":
		anim_player.stop()

func set_player_num(pnum):
	player_num = pnum
	
	var new_color = GlobalDict.player_data[player_num].color
	sprite.self_modulate = new_color
	eyes.set_visible(true)
	
	legs.set_color(new_color)
	body.m.jumper.update_aim_helper(new_color)

func set_team_num(tnum):
	team_num = tnum
	
	create_move_particles()

func update_scale(num):
	var max_points = GlobalDict.cfg.max_points_capacity
	var scale_per_point = (SCALE_BOUNDS.max - SCALE_BOUNDS.min)/float(max_points)
	
	var new_scale = SCALE_BOUNDS.min + num*scale_per_point
	new_scale = clamp(new_scale, SCALE_BOUNDS.min, SCALE_BOUNDS.max)
	
	if data.visuals.has('narrow'):
		new_scale *= GlobalDict.cfg.narrow_bug_upscale

	tween_scale_change(Vector2(1,1)*new_scale)
	
	body.z_index = num * 100
	
	body.m.collector.update_collision_shape(new_scale)

func tween_scale_change(new):
	set_scale(1.5*new)
	body.m.tween.interpolate_property(self, "scale",
		scale, new, 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	
	body.m.tween.start()

func on_move_type_changed(new_type):
	legs.on_move_type_changed(new_type)
	wings.on_move_type_changed(new_type)

func _on_WebTracker_teleported():
	legs.reset_legs()

func create_move_particles():
	var team_num = body.m.status.team_num
	
	var part_key = "res://assets/ui/team_icons/team_icon_small_" + str(team_num) + ".png"
	move_particles.texture = load(part_key)
	
	var player_num = body.m.status.player_num
	var part_modulate = Color.from_hsv(randf(), 0.5, 0.5)
	if player_num >= 0:
		part_modulate = GlobalDict.player_data[player_num].color
	
	move_particles.modulate = part_modulate
	
func _on_Mover_on_move_completed(vec):
	if not move_particles.is_emitting(): move_particles.set_emitting(true)

func _on_Mover_on_move_stopped():
	if not move_particles.is_emitting(): move_particles.set_emitting(false)

func _on_Tracker_on_switch():
	_on_Mover_on_move_stopped()
