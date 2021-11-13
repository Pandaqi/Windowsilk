extends Node

var scenes = {
	'menu': preload("res://Menu.tscn"),
	'main': preload("res://Main.tscn")
}

var custom_web_to_load : String = "menu"
var in_game : bool = false

func start_game():
	GlobalDict.update_from_current_config()
	in_game = true
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(scenes.main)
	

func back_to_menu():
	custom_web_to_load = "menu"
	in_game = false
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(scenes.menu)
