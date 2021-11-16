extends Node

onready var body = get_parent()
var active : bool = true
var is_shutdown : bool = false

var active_module = null

func select_module(key):
	if active_module and active_module.has_method("on_deselect"):
		active_module.on_deselect()
	
	active_module = get_node(key)
	
	if active_module.has_method('on_select'):
		active_module.on_select()

func shutdown():
	is_shutdown = true

func disable():
	active = false

func enable():
	if is_shutdown: return
	active = true

func _physics_process(dt):
	if not active_module: return
	if not active: return
	if not active_module.has_method("module_update"): return
	active_module.module_update(dt)

func _on_Status_on_death():
	disable()
	
	if not active_module.has_method("die"): return
	active_module.die()

func _on_Respawner_on_revive():
	enable()
	
	if not active_module.has_method("revive"): return
	active_module.revive()
