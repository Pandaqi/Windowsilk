extends Node2D

const BASE_COLOR : Color = Color(1,1,1)
var color : Color = Color(1,1,1)
var pattern : int = -1

var icon_width : float = 32.0
var original_icon_width : float = 128.0
var icon_scale = Vector2(1,1) * (icon_width / original_icon_width)
var full_pattern_length : float = 0.0
var icon_offset : float
var icon_margin : float = 3.0
var icon_extrude : float = 0.75 # how much the icon sticks out from the sides of the edge

var pattern_sprites = [[],[]]

onready var body = get_parent()
onready var sprite = $Sprite

onready var tween = get_node("/root/Main/Tween")

var team_icon_scene = preload("res://scenes/team_icon.tscn")

func update_visuals():
	var new_length = body.m.body.get_length()
	if abs(full_pattern_length - new_length) >= icon_width:
		recalculate_pattern()
	
	update()

func set_color(col):
	tween_color_change(col)
	color = col
	update()

func get_color():
	return color

func tween_color_change(col):
	tween.interpolate_property(self, "self_modulate",
		self_modulate, col, 0.6, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func set_icon(data):
	var frame = data.frame
	
	sprite.set_visible(true)
	
	var is_default_terrain = (frame == 0)
	if is_default_terrain:
		sprite.set_visible(false)
	
	var line_thickness = body.m.body.get_thickness()
	var full_scale : float = 128.0
	var new_scale =  Vector2(1,1) * (line_thickness / full_scale)
	
	if data.has('narrow'):
		new_scale *= GlobalDict.cfg.narrow_icon_upscale
	
	sprite.set_scale(new_scale)
	sprite.set_frame(frame)
	
	rotate_icon(0)

func rotate_icon(val):
	sprite.set_rotation(val)

func recalculate_pattern():
	if pattern < 0: return
	
	var old_num = pattern
	remove_pattern()
	set_pattern(old_num)

func remove_pattern():
	pattern = -1
	
	for arr in pattern_sprites:
		for sprite in arr:
			sprite.queue_free()
	
	pattern_sprites = [[],[]]

func set_pattern(num):
	var already_has_pattern = (pattern_sprites[0].size() > 0)
	if already_has_pattern: return
	
	# TO DO: set some icon? Update a shader to show a repeated version of an icon?
	pattern = num
	
	var num_icons = floor(body.m.body.get_length() / (icon_width + icon_margin))
	full_pattern_length = (num_icons-1)*(icon_width + icon_margin)
	icon_offset = -0.5*full_pattern_length
	
	var angles = [PI, 0]
	for i in range(num_icons):
		for j in range(2):
			var icon = team_icon_scene.instance()
			icon.set_scale(icon_scale)
			icon.set_frame(num)
			icon.set_rotation(angles[j])
			icon.show_behind_parent = true
			add_child(icon)
			pattern_sprites[j].append(icon)

	update()

func _draw():
	draw_rectangle()
	draw_pattern()

func draw_rectangle():
	var col_rect = body.m.body.col_shape.extents
	var rect = Rect2(-col_rect, 2*col_rect)

	draw_rect(rect, Color(1,1,1), true)
	
	if GlobalDict.cfg.draw_outlines_on_web:
		draw_rect(rect, Color(1,1,1).darkened(GlobalDict.cfg.outline_darkening), false, GlobalDict.cfg.outline_width, true)

func draw_pattern():
	var line_thickness = body.m.body.get_thickness()
	var ratio = body.m.boss.get_fade_ratio()
	
	var ortho_vecs = [Vector2.DOWN, Vector2.UP]
	for i in range(2):
		var ortho_vec = ortho_vecs[i]
		var arr = pattern_sprites[i]
		
		for j in range(arr.size()):
			var icon = arr[j]
			var pos = (j * (icon_width + icon_margin) + icon_offset)*Vector2.RIGHT + ortho_vec * icon_extrude * line_thickness
			icon.set_position(pos)
			icon.modulate = color.darkened(GlobalDict.cfg.outline_darkening)
			icon.modulate.a = ratio

func fade_icons(ratio):
	for arr in pattern_sprites:
		for sprite in arr:
			sprite.modulate.a = ratio

func play_creation_tween():
	tween.interpolate_property(self, "scale",
		Vector2(1,1)*1.5, Vector2(1,1), 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	
	
