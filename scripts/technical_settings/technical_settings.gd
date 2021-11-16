extends CanvasLayer

onready var cont = $Control/CenterContainer/VBoxContainer
onready var main_node = get_parent()

var setting_module_scene = preload("res://scenes/technical_settings_module.tscn")
var modules = []

var active : bool = false

func _ready():
	create_interface()
	hide()

func _on_Main_open_settings():
	GlobalAudio.play_static_sound("button")
	show()
	main_node.hide()

func _unhandled_input(ev):
	if not active: return
	
	# same controls for pausing and exiting, not only consistent, also saves me work
	if ev.is_action_released("pause"):
		_on_Back_pressed()

func hide():
	$Control.set_visible(false)
	get_tree().paused = false
	active = false
	
	for mod in modules:
		mod.release_focus()

func show():
	get_tree().paused = true
	
	$Control.set_visible(true)
	grab_focus_on_first()
	active = true

func grab_focus_on_first():
	modules[0].grab_focus_on_comp()

func create_interface():
	var st = GlobalConfig.settings
	
	for i in range(st.size()):
		var cur_setting = st[i]
		var node = setting_module_scene.instance()
		
		# set correct name and section,
		# so it knows WHICH entries to update
		node.initialize(cur_setting)
		
		# set to the current saved value in the config
		node.update_to_config()
		
		# add the whole thing
		cont.add_child(node)
		modules.append(node)
	
	# make sure the back button is at the BOTTOM
	var back_btn = cont.get_node("Back")
	cont.remove_child(back_btn)
	cont.add_child(back_btn)

func _on_Back_pressed():
	GlobalAudio.play_static_sound("button")
	
	self.hide()
	main_node.show()
