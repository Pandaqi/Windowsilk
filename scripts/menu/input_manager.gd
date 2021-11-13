extends Node2D

onready var players = get_node("/root/Main/Players")
onready var main_node = get_node("/root/Main")
onready var web = get_node("/root/Main/Web")

const CONFIG_TOGGLE_RADIUS : float = 20.0

func _unhandled_input(ev):
	if main_node.web_is("menu"):
		check_device_status(ev)
	
	elif main_node.web_is("bugs") or main_node.web_is("arenas"):
		check_option_toggle(ev)
	
	#GlobalInput.check_remove_player(ev)

func check_device_status(ev):
	var res = GlobalInput.check_new_player(ev)
	if not res.failed:
		players.create_new(GlobalInput.get_player_count() - 1)

func check_option_toggle(ev):
	var players = get_tree().get_nodes_in_group("Players")
	for i in range(GlobalInput.get_player_count()):
		var device_num = GlobalInput.device_order[i]
		
		if not ev.is_action_released("interact_" + str(device_num)): continue
		
		var p = players[i]
		var closest_point = get_closest_valid_point_to(p.position)
		
		if not closest_point: continue
		
		closest_point.m.menu.toggle()
		break

func get_closest_valid_point_to(p):
	return web.get_closest_point(p, CONFIG_TOGGLE_RADIUS)
