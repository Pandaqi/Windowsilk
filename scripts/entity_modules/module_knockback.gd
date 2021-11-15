extends Node2D

const MIN_SPEED : float = 70.0
const DAMPING : float = 0.9965

var vec : Vector2 = Vector2.ZERO

onready var body = get_parent()
var active : float = false

func apply(new_vec):
	vec += new_vec
	active = true

func _physics_process(dt):
	if not active: return
	
	body.m.mover._on_Movement_move_vec(vec, dt)
	vec *= DAMPING
	
	if vec.length() <= MIN_SPEED:
		vec = Vector2.ZERO
		active = false
