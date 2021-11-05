extends Node2D

const SCALE_BOUNDS = { 'min': 0.65, 'max': 1.5 }
const SCALE_PER_POINT = 0.05

onready var sprite = $Sprite
onready var body = get_parent()

func set_sprite(frm):
	sprite.set_frame(frm)

func set_move_type(tp):
	if tp == "web":
		$Legs.set_visible(true)
	else:
		$Legs.set_visible(false)

func update_scale(num):
	var new_scale = SCALE_BOUNDS.min + num*SCALE_PER_POINT
	new_scale = clamp(new_scale, SCALE_BOUNDS.min, SCALE_BOUNDS.max)
	set_scale(Vector2(1,1)*new_scale)
	
	body.m.collector.update_collision_shape(new_scale)
