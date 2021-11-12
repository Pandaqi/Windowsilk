extends Node2D

const COLOR : Color = Color(1,1,1)
onready var body = get_parent()
onready var tween = get_node("/root/Main/Tween")

func update_visuals():
	update()

func _draw():
	var radius = body.m.body.get_radius()
	draw_circle(Vector2.ZERO, radius, COLOR)
	
	if GlobalDict.cfg.draw_outlines_on_web:
		draw_arc(Vector2.ZERO, radius, 0, 2*PI, 16, COLOR.darkened(GlobalDict.cfg.outline_darkening), GlobalDict.cfg.outline_width, true)

func play_creation_tween():
	tween.interpolate_property(self, "scale",
		Vector2(1,1)*1.5, Vector2(1,1), 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
