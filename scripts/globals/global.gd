extends Node

var scenes = {
	'menu': preload("res://Menu.tscn"),
	'main': preload("res://Main.tscn")
}

var custom_web_to_load : String = "menu"

func start_game():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(scenes.main)

func back_to_menu():
	custom_web_to_load = "menu"
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(scenes.menu)
