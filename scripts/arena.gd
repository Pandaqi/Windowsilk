extends Node2D

var arena : String = "windowsill"

func activate():
	# DEBUGGING
	return
	
	arena = GlobalDict.cfg.arena
	
	var arena_scene = load("res://scenes/arenas/" + arena + ".tscn").instance()
	add_child(arena_scene)
	
	# TO DO: In the future (maybe)
	# => Allow them to have manually created webs; if so, create those instead
	# => Allow them custom functionality, which might need to be activated/copied somewhere else
