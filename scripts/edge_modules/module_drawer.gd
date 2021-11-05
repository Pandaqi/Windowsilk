extends Node2D

const BASE_COLOR : Color = Color(1,1,1)
var color : Color = Color(1,1,1)
var pattern : int = -1

onready var body = get_parent()
onready var sprite = $Sprite

func update_visuals():
	update()

func set_color(col):
	color = col
	update()

func set_icon(frame):
	var line_thickness = body.m.body.get_thickness()
	var full_scale : float = 128.0
	var new_scale = 2 * Vector2(1,1) * (line_thickness / full_scale)
	
	sprite.set_scale(new_scale)
	sprite.set_frame(frame)
	
	rotate_icon(0)

func rotate_icon(val):
	sprite.set_rotation(val)

func set_pattern(num):
	# TO DO: set some icon? Update a shader to show a repeated version of an icon?
	pattern = num
	update()

func _draw():
	var col_rect = body.m.body.col_shape.extents
	var rect = Rect2(-col_rect, 2*col_rect)

	draw_rect(rect, color, true)
