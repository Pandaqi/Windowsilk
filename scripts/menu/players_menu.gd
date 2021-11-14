extends "res://scripts/players.gd"

var starting_points = []
var prompts = []

var prompt_scene = preload("res://scenes/ui/prompt.tscn")
onready var main_node = get_node("/root/Main")

signal player_logged_in()

func activate():
	for i in range(GlobalInput.get_player_count()):
		create_new(i)
	
	show_next_register_prompt()

func create_new(num):
	var p = entity_scene.instance()
	web.entities.add_child(p)
	
	var team_num = num
	p.m.status.set_type("player_spider")
	p.m.status.make_player(num, team_num)
	p.m.status.make_menu_entity()
	
	p.m.mover.force_update_speed_scale(2.0)
	
	if main_node.web_is("arenas") or main_node.web_is("bugs"):
		p.m.jumper.disable_input()

	var start_point = starting_points[num]

	var params = {
		'fixed_point': start_point
	}
	p.m.status.initialize(params)
	
	start_point.m.drawer.set_color(GlobalDict.player_data[num].color)
	start_point.m.drawer.scale_radius(2.0)
	
	emit_signal("player_logged_in")
	
	prompts[num].set_frame(GlobalInput.get_tutorial_frame_for_player(num))
	show_next_register_prompt()

func advance_prompt(num):
	var cur_frame = prompts[num].get_frame()
	if cur_frame >= 5: return
	prompts[num].set_frame(cur_frame + 5)

func show_next_register_prompt():
	var next_player_num = GlobalInput.get_player_count()
	if next_player_num >= 6: return
	
	var val = true
	if not main_node.web_is("menu"):
		val = false
	
	prompts[next_player_num].set_visible(val)
	prompts[next_player_num].set_frame(10)

func add_starting_position(point, index):
	if starting_points.size() <= 0:
		starting_points.resize(6)
		prompts.resize(6)
	
	starting_points[index] = point
	
	var new_prompt = prompt_scene.instance()
	prompts[index] = new_prompt
	point.add_child(new_prompt)
	
	var flip = (index >= 1 and index <= 3)
	new_prompt.get_node("Sprite").flip_h = flip
	
	var offset = Vector2.LEFT*0.5*384.0
	if flip: 
		offset.x *= -1
		new_prompt.get_node("Sprite").set_position(Vector2.LEFT*50)
	
	new_prompt.set_position(offset)
	new_prompt.set_visible(false)

func _on_Main_team_changed(entity):
	var player_num = entity.m.status.player_num
	advance_prompt(player_num)
