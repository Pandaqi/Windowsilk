extends Node2D

var arena : String = "windowsill"

# DEBUGGING
export var debug_arena : String = ""

func activate():
	if debug_arena != "":
		GlobalDict.cfg.arena = debug_arena
	
	arena = GlobalDict.cfg.arena

	var arena_scene = load("res://scenes/arenas/" + arena + ".tscn").instance()
	add_child(arena_scene)
		
	
	# TO DO: In the future (maybe)
	# => Allow them to have manually created webs; if so, create those instead
	# => Allow them custom functionality, which might need to be activated/copied somewhere else
