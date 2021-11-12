extends Node2D

var fb_scene = preload("res://scenes/ui/fb.tscn")

func create(pos, txt):
	var fb = fb_scene.instance()
	fb.get_node("Label").set_text(str(txt))
	fb.set_position(pos)
	add_child(fb)
