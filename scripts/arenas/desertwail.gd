extends Node2D

const NUM_DUST_CLOUDS : int = 2

var dc_scene = preload("res://scenes/arenas/dust_cloud.tscn")
onready var web = get_node("/root/Main/Web")

func _ready():
	create_dust_clouds()

func create_dust_clouds():
	for i in range(NUM_DUST_CLOUDS):
		create_dust_cloud()

func create_dust_cloud():
	var cloud = dc_scene.instance()
	web.overlay.add_child(cloud)
	cloud.reset()
