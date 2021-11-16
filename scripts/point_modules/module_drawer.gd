extends Node2D

var COLOR : Color = Color(1,1,1)
onready var body = get_parent()
onready var tween = get_node("/root/Main/Tween")
onready var arena = get_node("/root/Main/Arena")

var radius_scale_factor : float = 1.0

var sprite = null
var custom_img = null

func _ready():
	var custom_point = arena.get_custom_point()
	if custom_point:
		custom_img = load("res://assets/custom_points/" + custom_point + ".png")
		
		sprite = Sprite.new()
		sprite.texture = custom_img
		sprite.set_rotation(2*PI*randf())
		add_child(sprite)
		

func update_visuals():
	update()

func set_color(col):
	COLOR = col
	update()

func scale_radius(rs):
	radius_scale_factor = rs
	update()

func _draw():
	var radius = body.m.body.get_radius()*radius_scale_factor
	
	if custom_img:
		sprite.set_visible(true)
		sprite.set_scale((radius/128.0)*Vector2(1,1)*2.0)
		return
	
	draw_circle(Vector2.ZERO, radius, COLOR)
	
	if GlobalDict.cfg.draw_outlines_on_web:
		draw_arc(Vector2.ZERO, radius, 0, 2*PI, 16, COLOR.darkened(GlobalDict.cfg.outline_darkening), GlobalDict.cfg.outline_width, true)

func play_creation_tween():
	tween.interpolate_property(self, "scale",
		Vector2(1,1)*1.5, Vector2(1,1), 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
