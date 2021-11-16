extends Node2D

const SPEED_BOUNDS = { 'min': 40, 'max': 80 }
const TIMER_BOUNDS = { 'min': 7.0, 'max': 10.0 }
const SCALE_BOUNDS = { 'min': 0.725, 'max': 1.0 }
const CLOUD_SIZE : float = 512.0

const GUST_FORCE : float = 300.0

var force
var speed : float

onready var area = $Area2D
onready var tween = $Tween
onready var timer = $Timer

func _ready():
	restart_timer()

func reset():
	var start_data = get_random_position()
	set_position(start_data.pos)
	
	var vec_to_center = start_data.vec
	var rand_vec = (-vec_to_center).rotated((randf()-0.5)*0.4*PI)
	set_force(rand_vec)
	set_random_speed()
	set_random_scale()
	
	set_rotation(2*PI*randf())

func set_force(vec : Vector2):
	force = vec

func set_random_speed():
	speed = rand_range(SPEED_BOUNDS.min, SPEED_BOUNDS.max)

func set_random_scale():
	scale = Vector2(1,1)*rand_range(SCALE_BOUNDS.min, SCALE_BOUNDS.max)

func _physics_process(dt):
	set_position(get_position() + force*speed*dt)
	
	if out_of_bounds():
		reset()

func out_of_bounds():
	var half_size = 0.5*CLOUD_SIZE
	var p = position
	
	return p.x < -half_size or p.x > 1920+half_size or p.y < -half_size or p.y > 1080+half_size

func get_random_position():
	var half_size = 0.5*CLOUD_SIZE
	var x
	var y
	
	if randf() <= 0.5:
		x = -half_size if randf() <= 0.5 else 1920+half_size
		y = randf()*1080
	
	else:
		x = randf()*1920
		y = -half_size if randf() <= 0.5 else 1080+half_size
	
	var vec
	if x < 0:
		vec = Vector2.RIGHT
	elif x > 1920:
		vec = Vector2.LEFT
	elif y < 0:
		vec = Vector2.UP
	elif y > 0: 
		vec = Vector2.DOWN
	
	return {
		'pos': Vector2(x,y),
		'vec': vec
	}

func restart_timer():
	timer.wait_time = rand_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func _on_Timer_timeout():
	blast_away_entities()
	play_blast_tweens()

func blast_away_entities():
	for b in area.get_overlapping_bodies():
		if not b.is_in_group("Entities"): continue
		
		var vec_away = (b.position - position).normalized()
		b.m.knockback.apply(vec_away * GUST_FORCE)
	
	GlobalAudio.play_dynamic_sound(self, "gust_of_wind")

func play_blast_tweens():
	tween.interpolate_property(self, "rotation",
		rotation, rotation+2*PI, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "scale",
		scale*1.3, scale, 0.5,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	
	tween.start()
