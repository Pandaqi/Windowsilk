extends Node2D

const COLOR : Color = Color(1,1,1)
onready var body = get_parent()

func update_visuals():
	update()

func _draw():
	var radius = body.m.body.get_radius()
	draw_circle(Vector2.ZERO, radius, COLOR)
	
	if GlobalDict.cfg.draw_outlines_on_web:
		draw_arc(Vector2.ZERO, radius, 0, 2*PI, 16, COLOR.darkened(0.5), GlobalDict.cfg.outline_width, true)
