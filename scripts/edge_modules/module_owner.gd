extends Node2D

var boss = null
onready var body = get_parent() 

func set_to(b):
	boss = b
	
	body.m.drawer.set_pattern(boss.m.status.team_num)

func can_enter(entity):
	if not boss: return true
	return boss.m.status.team_num == entity.m.status.team_num
