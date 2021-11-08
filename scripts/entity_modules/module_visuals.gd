extends Node2D

const SCALE_BOUNDS = { 'min': 0.65, 'max': 1.5 }
const SCALE_PER_POINT = 0.05

onready var sprite = $Sprite
onready var eyes = $Sprite/Eyes
onready var legs = $Legs
onready var antenna = $Antenna
onready var worm = $Worm
onready var body = get_parent()

var player_num : int = -1

func set_data(data):
	sprite.set_frame(data.frame)
	
	if data.has('legs'):
		legs.initialize(data.legs)
	
	if data.has('antenna'):
		antenna.initialize(data.antenna)
	
	if data.move.has('worm'):
		worm.initialize()

func set_player_num(pnum):
	player_num = pnum
	
	var new_color = GlobalDict.player_data[player_num].color
	sprite.self_modulate = new_color
	eyes.set_visible(true)
	
	legs.set_color(new_color)

func update_scale(num):
	var new_scale = SCALE_BOUNDS.min + num*SCALE_PER_POINT
	new_scale = clamp(new_scale, SCALE_BOUNDS.min, SCALE_BOUNDS.max)
	set_scale(Vector2(1,1)*new_scale)
	
	body.m.collector.update_collision_shape(new_scale)
