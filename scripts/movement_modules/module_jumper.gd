extends Node2D

const TIME_BOUNDS = { 'min': 2, 'max': 3 }
const TURN_SPEED : float = 1.0

onready var timer = $Timer
onready var movement_handler = get_parent()
onready var body = movement_handler.get_parent()

var target_vec : Vector2
var is_jumping : bool = false
var active : bool = false

func activate():
	active = true
	
	pick_new_vec()
	restart_timer()

func _on_Timer_timeout():
	body.m.jumper._on_Input_button_press()

func restart_timer():
	timer.wait_time = rand_range(TIME_BOUNDS.min, TIME_BOUNDS.max)
	timer.start()

func pick_new_vec():
	if target_vec.length() <= 0.03: 
		target_vec = Vector2.RIGHT
	
	var rand_rot = 0.5*PI + randf()*1.5*PI
	target_vec = target_vec.rotated(rand_rot)

func _physics_process(dt):
	if not active: return
	if is_jumping: return
	
	var cur_rot = body.rotation
	var cur_vec = Vector2(cos(cur_rot), sin(cur_rot))
	
	var new_vec = cur_vec.slerp(target_vec, TURN_SPEED * dt)
	body.set_rotation(new_vec.angle())
	
	if (new_vec-target_vec).length() <= 0.05:
		jump()

func jump():
	# too soon (we just jumped), pick a new vec and ignore this
	if timer.time_left > 0:
		pick_new_vec()
		return
	
	# direction isn't valid
	var params = body.m.jumper.determine_jump_details()
	params.dir = target_vec
	if not body.m.jumper.is_dir_valid(params):
		pick_new_vec()
		return
	
	params.dont_create_new_edges = true
	
	is_jumping = true
	body.m.jumper._on_Input_button_release(params)

func _on_Jumper_on_jump_finished():
	if not active: return
	
	is_jumping = false
	restart_timer()
	pick_new_vec()
