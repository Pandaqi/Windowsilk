extends Node2D

var type : String = "regular"
var data

onready var body = get_parent()

func set_to(tp):
	type = tp
	data = GlobalDict.silk_types[type]
	
	# TO DO: Also place an icon on top of the line, centred
	
	body.m.drawer.set_color(data.color)

func equals(tp):
	return type == tp

func get_it():
	return type
