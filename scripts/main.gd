extends Node2D

onready var web = $Web
onready var spawner = $Spawner
onready var players = $Players

func _ready():
	if GlobalInput.get_player_count() <= 0:
		GlobalInput.create_debugging_players()
	
	web.activate()

func web_loading_done():
	players.activate()
	spawner.activate()
