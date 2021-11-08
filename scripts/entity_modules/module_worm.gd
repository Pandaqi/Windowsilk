extends Node2D

const LENGTH_BOUNDS = { 'min': 0.45, 'max': 1.0 }

var active : bool = false
var phase : String = 'compress'

onready var visuals = get_parent()
onready var body = visuals.get_parent()

onready var butt = $Back
onready var head = $Front

var full_length : float

func initialize():
	active = true
	full_length = (Vector2.ZERO - butt.position).length()
	visuals.antenna.set_position(-0.5*full_length*Vector2.RIGHT)

func position_sprite_between_points():
	var local_butt = butt.position
	var local_head = Vector2.ZERO
	
	var center = 0.5*(local_butt + local_head)
	visuals.sprite.set_position(center)

	var new_scale = Vector2(get_length_ratio(), 1)
	visuals.sprite.set_scale(0.33*new_scale)

func get_length_ratio():
	var local_butt = butt.position
	var local_head = Vector2.ZERO
	
	var cur_length : float = (local_head - local_butt).length()
	
	return (cur_length / full_length)

# NOTE: Returns whether movement should be stopped/hijacked or not
func receive_move_vector(vec):
	if not active: return false
	
	vec = vec.rotated(-body.rotation)

	if phase == 'compress':
		butt.position += vec
		check_phase_switch()
		update()
		return true
	else:
		butt.position -= vec
		update()
		return false

func check_phase_switch():
	var length_ratio = get_length_ratio()
	
	if phase == 'compress' and length_ratio <= LENGTH_BOUNDS.min:
		phase = 'extend'
	elif phase == 'extend' and length_ratio >= LENGTH_BOUNDS.max:
		phase = 'compress'

func _on_Mover_on_move_completed(vec):
	if not active: return
	
	check_phase_switch()
	position_sprite_between_points()

func _draw():
	return
	draw_circle(butt.position, 10, Color(0,1,0))
	draw_circle(Vector2.ZERO, 10, Color(1,0,0))
	
	
	
