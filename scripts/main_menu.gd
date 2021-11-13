extends Node2D

onready var web = $Web
onready var entities = $Entities
onready var players = $Players

signal team_changed(entity)
signal players_nearby(is_true, type)
signal open_settings()

func _ready():
	web.custom_web = Global.custom_web_to_load
	web.activate()

func web_loading_done():
	entities.activate()
	players.activate()
	print("LOADING DONE")
