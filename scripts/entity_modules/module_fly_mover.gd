extends Node2D

const BASE_SPEED : float = 50.0
var speed : float = BASE_SPEED

onready var body = get_parent()
var active : bool = true

# TO DO: For each of the "double" modules (FlyMover/WebMover, FlyMovement/WebMovement), create a general script they inherit from, containing any duplicate functionality

# TO DO: Also just _merge_ the entity and player scenes into one? And destroy any player modules on non-players? Now I often need to copy its behavior
func _on_Input_move_vec(vec, _dt):
	if not active: return

	var not_moving = (vec.length() <= 0.03)
	if not_moving: return
	
	var final_move_vec = vec
	var final_move_speed = speed
	
	body.move_and_slide(final_move_vec * final_move_speed)
	body.set_rotation(final_move_vec.angle())

func disable():
	active = false

func enable():
	active = true

func set_speed(sp):
	speed = sp
