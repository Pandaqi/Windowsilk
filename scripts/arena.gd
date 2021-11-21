extends Node2D

var arena : String = "windowsill"
var arena_scene = null
var data = {}

const SPLASH_KNOCKBACK_RADIUS : float = 100.0
const SPLASH_KNOCKBACK_FORCE : float = 440.0

onready var particles = get_node("/root/Main/Particles")

export var menu_arena : bool = false

# DEBUGGING
export var debug_arena : String = ""

func activate():
	if menu_arena: return
	
	if debug_arena != "":
		GlobalDict.cfg.arena = debug_arena
	
	arena = GlobalDict.cfg.arena
	data = GlobalDict.arenas[arena]

	arena_scene = load("res://scenes/arenas/" + arena + ".tscn").instance()
	add_child(arena_scene)
	
	if not arena_scene.script or not arena_scene.has_method("prepare"): return
	arena_scene.prepare()

func web_loading_done():
	if not arena_scene: return
	if not arena_scene.script or not arena_scene.has_method("activate"): return
	arena_scene.activate()

func prepare_entity_placement():
	if not arena_scene: return
	if not arena_scene.script or not arena_scene.has_method("prepare_entity_placement"): return
	arena_scene.prepare_entity_placement()

func has_global_specialty(tp : String):
	if not data.has('global_specialty'): return false
	return data.global_specialty == tp

func execute_knockback(pos : Vector2):
	if not data.has('create_splash_knockbacks'): return
	
	$BlastCenter.set_position(pos)
	
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
	
	particles.create_blast_particles(pos)
	GlobalAudio.play_dynamic_sound($BlastCenter, "water_splash")

func hijack_entity_placement(body):
	if not arena_scene: return null
	if not arena_scene.script: return null
	if not arena_scene.has_method("hijack_entity_placement"): return null
	if body.m.status.is_player(): return null
	
	return arena_scene.hijack_entity_placement(body)

func get_custom_point():
	if not arena_scene: return null
	if not data.has('custom_point'): return null
	return data.custom_point
