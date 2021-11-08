extends Node2D

const MIN_SPEED : float = 20.0
const DAMPING : float = 0.995

var vec : Vector2 = Vector2.ZERO

onready var body = get_parent()

func apply(new_vec):
	vec = new_vec

func _physics_process(dt):
	if vec.length() <= 0.03: return
	
	body.m.mover._on_Movement_move_vec(vec, dt)
	vec *= DAMPING
	
	if vec.length() <= MIN_SPEED:
		vec = Vector2.ZERO
