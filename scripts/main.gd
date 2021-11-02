extends Node2D

onready var web = $Web

func _ready():
	if GlobalInput.get_player_count() <= 0:
		GlobalInput.create_debugging_players()
	
	web.activate()
