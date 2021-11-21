extends Node2D

const TIMER_BOUNDS = { 'min': 16, 'max': 30 }
const LARVA_HELP_RADIUS : float = 150.0

onready var players = get_parent()
onready var web = get_node("/root/Main/Web")
onready var entities = get_node("/root/Main/Entities")
onready var timer = $Timer

func _ready():
	restart_timer()
	
func _on_Timer_timeout():
	restart_timer()
	place_helper_larva()

func restart_timer():
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func place_helper_larva():
	var teams = players.get_teams_in_play()
	for team_num in teams:
		var team_has_low_players = false # points below 1
		var team_nodes = players.get_players_in_team(team_num)
		
		for node in team_nodes:
			if node.m.points.count() <= 0:
				team_has_low_players = true
				break
			
			if node.m.points.count() <= 1 and randf() <= 0.75:
				team_has_low_players = true
				break
		
		if not team_has_low_players: continue
		
		var home_base = web.home_bases[team_num]
		var params = {
			'type': 'larva',
			'nearby_point': home_base,
			'nearby_radius': LARVA_HELP_RADIUS
		}
		
		entities.place_entity(params)
