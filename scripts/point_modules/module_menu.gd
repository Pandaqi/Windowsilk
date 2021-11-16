extends Node2D

var type : String = ""
var num_players_here : int = 0
var num_players_nearby : int = 0
var team_num : int = -1

var react_to_nearby_players = ["arenas", "bugs", "settings", "quit", "config", "play"]

onready var body = get_parent()
onready var feedback = get_node("/root/Main/Feedback")
onready var main_node = get_node("/root/Main")

var bug_icon = preload("res://scenes/ui/bug_icon.tscn")
var arena_icon = preload("res://scenes/ui/arena_icon.tscn")

var bug_tutorial = preload("res://scenes/ui/bug_tutorial.tscn")
var arena_tutorial = preload("res://scenes/ui/arena_tutorial.tscn")

onready var tween = $Tween

const TUTORIAL_SHOW_RADIUS : float = 30.0
const PLAY_DETECT_RADIUS : float = 150.0

# TO DO: Very ugly, but it works for now
var item_name = null
var item_list
var item_type
var item_data
var item_icon = null
var item_tutorial

var toggled : bool = false

func set_type(tp):
	type = tp
	
	if type == "config":
		var shp = $Area2D/CollisionShape2D.shape.duplicate(true)
		shp.radius = TUTORIAL_SHOW_RADIUS
		$Area2D/CollisionShape2D.shape = shp
	elif type == "play":
		var shp = $Area2D/CollisionShape2D.shape.duplicate(true)
		shp.radius = PLAY_DETECT_RADIUS
		$Area2D/CollisionShape2D.shape = shp

func on_entity_enter(e):
	if type == "": return
	
	if e.is_in_group("Players"):
		num_players_here += 1
	
	check_for_action(e)

func check_for_action(e):
	if num_players_here <= 0: return
	if not e.is_in_group("Players"): return
	
	# TO DO: Custom functionalities for menu here
	if type == "start":
		pass
		
	elif type == "team":
		GlobalDict.player_data[e.m.status.player_num].team = team_num
		e.m.status.change_team(team_num)
		feedback.create(body.position, "Changed team!")
		main_node.emit_signal("team_changed", e)
		
	elif type == "settings":
		GlobalAudio.play_static_sound("button")
		main_node.emit_signal("open_settings")
		
	elif type == "bugs":
		GlobalAudio.play_static_sound("button")
		Global.custom_web_to_load = "bugs"
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
		
	elif type == "arenas":
		GlobalAudio.play_static_sound("button")
		Global.custom_web_to_load = "arenas"
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
		
	elif type == "quit":
		GlobalAudio.play_static_sound("button")
		get_tree().quit()
	
	elif type == "exit":
		GlobalAudio.play_static_sound("button")
		Global.custom_web_to_load = "menu"
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()

func on_entity_exit(e):
	if type == "": return
	if e.is_in_group("Players"):
		num_players_here -= 1

func start_game():
	Global.start_game()

func _on_Area2D_body_entered(other_body):
	if not other_body.is_in_group("Players"): return
	if not (type in react_to_nearby_players): return
	
	num_players_nearby += 1
	
	if num_players_nearby > 0:
		main_node.emit_signal("players_nearby", true, type)
		on_players_nearby(true)

func _on_Area2D_body_exited(other_body):
	if not other_body.is_in_group("Players"): return
	if not (type in react_to_nearby_players): return
	
	num_players_nearby -= 1
	
	if num_players_nearby <= 0:
		main_node.emit_signal("players_nearby", false, type)
		on_players_nearby(false)

func make_config_item(itm_name, itm_type, lst):
	item_name = itm_name
	item_type = itm_type
	item_list = lst
	item_data = item_list[item_name]
	
	# set icon and tutorial sprite
	if item_type == "bugs":
		item_icon = bug_icon.instance()
		item_tutorial = bug_tutorial.instance()
	elif item_type == "arenas":
		item_icon = arena_icon.instance()
		item_tutorial = arena_tutorial.instance()
	
	item_icon.set_frame(item_data.frame)
	item_tutorial.set_frame(item_data.frame)
	item_tutorial.modulate.a = 0.0
	
	var y_offset = -200
	if body.position.y < 0.5*1080:
		y_offset *= -1
	
	add_child(item_icon)
	feedback.add_child(item_tutorial)
	item_tutorial.set_position(body.position + Vector2(0, y_offset))
	
	read_value_from_config()

func read_value_from_config():
	var val = GlobalConfig.read_game_config(item_type, item_name)
	
	if val:
		turn_on(false)
		toggled = true
	else:
		turn_off(false)
		toggled = false

func turn_on(play_sound = true):
	var radius = 2
	if item_type == "arenas": radius = 3
	
	body.m.drawer.scale_radius(radius)
	body.m.drawer.set_color(Color(0,1,0))
	item_icon.modulate.a = 1.0
	
	if play_sound:
		GlobalAudio.play_static_sound("button")

func turn_off(play_sound = true):
	var radius = 1.5
	if item_type == "arenas": radius = 2
	
	body.m.drawer.scale_radius(radius)
	body.m.drawer.set_color(Color(0,0,0))
	item_icon.modulate.a = 0.5
	
	if play_sound:
		GlobalAudio.play_static_sound("button")

func toggle(forced = false):
	if not item_name: return
	
	var single_selection_mode = (item_type == "arenas")
	if (single_selection_mode and toggled) and not forced: 
		return
	
	toggled = not toggled
	
	if single_selection_mode and toggled and (not forced):
		force_turn_off_all_other_points()
	
	if toggled:
		turn_on()
	else:
		turn_off()
	
	GlobalConfig.update_game_config(item_type, item_name, toggled)

func force_turn_off_all_other_points():
	var points = get_tree().get_nodes_in_group("Points")
	for p in points:
		if not p.m.menu.toggled: continue
		if p == body: continue
		p.m.menu.toggle(true)

func on_players_nearby(val):
	if type == "play":
		if num_players_nearby >= GlobalInput.get_player_count():
			GlobalAudio.play_static_sound("button")
			start_game()
	
	elif type == "config":
		if val: show_tutorial()
		else: fade_tutorial()

func show_tutorial():
	if not item_tutorial: return
	tween.interpolate_property(item_tutorial, "modulate",
		item_tutorial.modulate, Color(1,1,1,1), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func fade_tutorial():
	if not item_tutorial: return
	tween.interpolate_property(item_tutorial, "modulate",
		item_tutorial.modulate, Color(1,1,1,0), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
