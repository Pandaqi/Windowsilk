extends Node2D

const BASE_COLOR : Color = Color(1,1,1)
var color : Color = Color(1,1,1)
var pattern : int = -1

onready var body = get_parent()

func update_visuals():
	update()

func set_color(col):
	color = col
	update()

func set_pattern(num):
	# TO DO: set some icon? Update a shader to show a repeated version of an icon?
	pattern = num
	update()

func _draw():
	var col_rect = body.m.body.col_shape.extents
	var rect = Rect2(-col_rect, 2*col_rect)

	draw_rect(rect, color, true)
