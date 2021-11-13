extends Node2D

var points = []

func add_config_point(p, index):
	if index >= points.size():
		points.resize(index+1)
	
	points[index] = p

func visualize(key):
	var list = GlobalDict.get_list_corresponding_with_key(key)
	var keys = list.keys()
	
	var ignore_keys = ['player_spider']
	for ignore_key in ignore_keys:
		keys.erase(ignore_key)
	
	var item_type = key
	for i in range(keys.size()):
		var p = points[i]
		var item_name = keys[i]
		
		p.m.menu.make_config_item(item_name, item_type, list)
		
		print("ASSIGNED")
		print(item_name)
