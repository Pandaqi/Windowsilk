extends Node2D

onready var mover_handler = get_parent()
onready var body = mover_handler.get_parent()

const TURN_SPEED : float = 8.0

var vec : Vector2 = Vector2.ZERO
var speed

func _on_Input_move_vec(new_vec, _dt):
	vec = new_vec

func stop():
	vec = Vector2.ZERO

func module_update(dt):
	if vec.length() <= 0.03: return
	
	var rot = body.rotation
	var forward_vec = Vector2(cos(rot), sin(rot))
	
	var final_vec = forward_vec.slerp(vec.normalized(), TURN_SPEED * dt)
	var final_move_speed = mover_handler.get_final_speed()
	
	body.move_and_slide(final_vec*final_move_speed)
	body.set_rotation(final_vec.angle())
