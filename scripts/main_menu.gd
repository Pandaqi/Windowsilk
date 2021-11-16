extends Node2D

onready var web = $Web
onready var entities = $Entities
onready var players = $Players
onready var config_loader = $ConfigLoader

# warning-ignore:unused_signal
signal team_changed(entity)
# warning-ignore:unused_signal
signal players_nearby(is_true, type)
# warning-ignore:unused_signal
signal open_settings()

var final_web : String

# DEBUGGING
export var debug_web : String = ""

func _ready():
	final_web = Global.custom_web_to_load
	if debug_web != "":
		final_web = debug_web
	
	if not web_is("menu"):
		$Helpers.queue_free()

	web.custom_web = final_web
	web.activate()

func web_loading_done():
	if web_is("menu"): entities.activate()
	players.activate()
	
	if web_is("arenas") or web_is("bugs"):
		config_loader.visualize(final_web)
	
	print("LOADING DONE")

func web_is(key):
	return final_web == key

func hide():
	pass

func show():
	pass
