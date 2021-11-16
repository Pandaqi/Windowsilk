extends Node2D

onready var mover_handler = get_parent()
onready var body = mover_handler.get_parent()

onready var web = get_node("/root/Main/Web")

const TURN_SPEED : float = 8.0
const BOUND_KNOCKBACK_FORCE : float = 20.0

var vec : Vector2 = Vector2.ZERO
var speed

var MOVE_AUDIO_VOLUME : float = -3.0
var audio_player

func on_select():
	if not body.m.status.is_player():
		MOVE_AUDIO_VOLUME *= 2
	
	audio_player = GlobalAudio.play_dynamic_sound(body, "move_wings", MOVE_AUDIO_VOLUME, "FX", false)

func on_deselect():
	audio_player.stop()
	audio_player.queue_free()

func _on_Input_move_vec(new_vec, _dt):
	vec = new_vec

func stop():
	if audio_player.is_playing(): audio_player.stop()
	vec = Vector2.ZERO

func module_update(dt):
	if vec.length() <= 0.03: return
	
	if not audio_player.is_playing(): audio_player.play()
	audio_player.set_position(body.position)
	
	var cur_pos = body.position
	var rot = body.rotation
	var forward_vec = Vector2(cos(rot), sin(rot))
	
	var final_vec = forward_vec.slerp(vec.normalized(), TURN_SPEED * dt)
	var final_move_speed = mover_handler.get_final_speed()
	
	var projected_pos = body.position + final_vec*final_move_speed*dt
	if web.is_out_of_bounds(projected_pos):
		body.m.status.give_constant_feedback("Stay on screen!")
		body.set_rotation((-final_vec).angle())
		body.m.knockback.apply(-final_vec*BOUND_KNOCKBACK_FORCE)
		return
	
	var res = body.m.specialties.forbidden_due_to_one_way(final_vec)
	if res: return
	
	body.move_and_slide(final_vec*final_move_speed)
	body.set_rotation(final_vec.angle())
	
	var new_pos = body.position
	mover_handler.emit_signal("on_move_completed", (new_pos - cur_pos))
