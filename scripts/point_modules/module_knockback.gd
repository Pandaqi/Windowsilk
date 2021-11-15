extends Node2D

const DAMPING : float = 0.95
const MIN_SPEED : float = 15.0

var vec : Vector2
var active : bool = false

onready var body = get_parent()

func apply(new_vec):
	vec += new_vec
	active = true

func _physics_process(dt):
	if not active: return
	
	body.m.body.move(vec, dt)
	
	vec *= DAMPING
	if vec.length() <= MIN_SPEED:
		vec = Vector2.ZERO
		active = false
