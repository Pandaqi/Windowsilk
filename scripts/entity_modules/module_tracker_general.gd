extends "res://scripts/module_selector.gd"

signal arrived_on_point(p)
signal arrived_on_edge(e)

func initialize(params):
	active_module.initialize(params)

# TO DO: A bit messy, checking if method exists or not.
# The reason this method won't exist for most trackers, is beacuse these are only sensible for WEB movement => so I should find a way to lock it there and not have to expose it
func arrived_on_point(p):
	if not active_module.has_method("arrived_on_point"): return
	active_module.arrived_on_point(p)

func arrived_on_edge(e):
	if not active_module.has_method("arrived_on_edge"): return
	active_module.arrived_on_edge(e)

func force_change_edge(e):
	if not active_module.has_method("force_change_edge"): return
	active_module.force_change_edge(e)

func get_current_edge():
	if not active_module.has_method("get_current_edge"): return
	return active_module.get_current_edge()

func get_current_point():
	if not active_module.has_method("get_current_point"): return
	return active_module.get_current_point()


