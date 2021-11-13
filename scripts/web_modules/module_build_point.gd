extends Node2D

export var type : String = ""
export var starting_index : int = -1
export var team_num : int = -1
export var config_index : int = -1

export var color : Color = Color(1,1,1,1)
export var scale_factor : float = 1.0

# pass our custom properties (set manually) to the real point created for us)
func add_properties_to_real(p):
	
	# any nodes from us are copied over, underneath the "visuals" part
	# (as those are mostly special sprites to display)
	for child in get_children():
		child.get_parent().remove_child(child)
		p.m.drawer.add_child(child)
	
	if type != "":
		p.m.menu.set_type(type)
	
	if team_num >= 0:
		p.m.menu.team_num = team_num
	
	p.m.drawer.set_color(color)
	p.m.drawer.scale_radius(scale_factor)
	
	p.m.body.scale_collision_shape(scale_factor)
	
	if starting_index >= 0:
		var players = get_node("/root/Main/Players")
		players.add_starting_position(p, starting_index)
	
	if type == "config":
		var config_loader = get_node("/root/Main/ConfigLoader")
		config_loader.add_config_point(p, config_index)
