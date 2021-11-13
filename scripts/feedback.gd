extends CanvasLayer

var fb_scene = preload("res://scenes/ui/fb.tscn")
var death_fb_scene = preload("res://scenes/ui/death_fb.tscn")

func create(pos, txt):
	var fb = fb_scene.instance()
	fb.get_node("Label").set_text(str(txt))
	fb.set_position(pos)
	add_child(fb)

func create_death_feedback(pos):
	var fb = death_fb_scene.instance()
	fb.set_position(pos)
	add_child(fb)
