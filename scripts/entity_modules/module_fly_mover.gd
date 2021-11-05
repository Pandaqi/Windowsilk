extends Node2D

onready var mover_handler = get_parent()
onready var body = mover_handler.get_parent()

func _on_Input_move_vec(vec, _dt):
	var final_move_vec = vec
	var final_move_speed = mover_handler.speed
	
	body.move_and_slide(final_move_vec * final_move_speed)
	body.set_rotation(final_move_vec.angle())
