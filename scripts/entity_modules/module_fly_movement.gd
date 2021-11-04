extends Node2D

const TIMER_BOUNDS = { 'min': 2, 'max': 6 }
const RAYCAST_DISTANCE = 50

var vec : Vector2

onready var body = get_parent()
onready var timer = $Timer
onready var rc = $RayCast2D
onready var spawner = get_node("/root/Main/Spawner")

signal move_vec(vec, dt)

func _physics_process(dt):
	check_raycast()
	emit_signal("move_vec", vec, dt)

func check_raycast():
	rc.cast_to = Vector2.RIGHT * RAYCAST_DISTANCE
	if not rc.is_colliding(): return
	
	# if we're about to hit the edge of the screen, rotate ourselves randomly AWAY from the bound
	var body = rc.get_collider()
	if body.is_in_group("Bounds"):
		var normal = rc.get_collision_normal()
		var rand_rot = (randf() - 0.5)*PI
		vec = normal.rotated(rand_rot)
		restart_timer()

func start_randomly(params):
	params.avoid_web = true
	
	var data = spawner.get_valid_random_position(params)
	
	body.set_position(data.pos)
	_on_Timer_timeout()

func pick_new_vec():
	var rot = 2*PI*randf()
	vec = Vector2(cos(rot), sin(rot))

func _on_Timer_timeout():
	restart_timer()
	pick_new_vec()

func restart_timer():
	timer.stop()
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()
