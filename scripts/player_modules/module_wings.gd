extends Node2D

onready var anim_player = $AnimationPlayer
var planned_animation = null

var active : bool = false

func disable():
	set_visible(false)
	active = false

# TO DO: do something with the data
func initialize(data):
	pass
	
	active = true
	set_visible(true)

func on_move_type_changed(new_type):
	if not active: return
	
	if new_type == "web":
		anim_player.play("WingCollapse")
		planned_animation = null
	else:
		anim_player.play_backwards("WingCollapse")
		planned_animation = "WingFlap"

func _on_AnimationPlayer_animation_finished(anim_name):
	if not planned_animation: return
	
	anim_player.play(planned_animation)
	planned_animation = null
