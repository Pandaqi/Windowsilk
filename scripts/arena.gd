extends Node2D

var arena : String = "windowsill"
var data

const SPLASH_KNOCKBACK_RADIUS : float = 100.0
const SPLASH_KNOCKBACK_FORCE : float = 500.0

# DEBUGGING
export var debug_arena : String = ""

func activate():
	if debug_arena != "":
		GlobalDict.cfg.arena = debug_arena
	
	arena = GlobalDict.cfg.arena
	data = GlobalDict.arenas[arena]

	var arena_scene = load("res://scenes/arenas/" + arena + ".tscn").instance()
	add_child(arena_scene)
		
	
	# TO DO: In the future (maybe)
	# => Allow them to have manually created webs; if so, create those instead
	# => Allow them custom functionality, which might need to be activated/copied somewhere else

func has_global_specialty(tp : String):
	if not data.has('global_specialty'): return false
	return data.global_specialty == tp

func execute_knockback(pos : Vector2):
	if not data.has('create_splash_knockbacks'): return
	
	var space_state = get_world_2d().direct_space_state

	var shp = CircleShape2D.new()
	shp.radius = SPLASH_KNOCKBACK_RADIUS
	
	var query_params = Physics2DShapeQueryParameters.new()
	query_params.set_shape(shp)
	query_params.transform.origin = pos
	query_params.collision_layer = 8 # points only, layer 4 = 2^3 = 8
	
	var result = space_state.intersect_shape(query_params)
	for res in result:
		var col = res.collider
		if not col.is_in_group("Points"): continue
		
		var vec_away = (col.position - pos).normalized()
		res.collider.m.knockback.apply(vec_away * SPLASH_KNOCKBACK_FORCE)
