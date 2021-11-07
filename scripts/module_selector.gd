extends Node

onready var body = get_parent()
var active : bool = true

var active_module = null

func select_module(key):
	active_module = get_node(key)

func disable():
	active = false

func enable():
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
