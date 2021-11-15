extends Node2D

export var line_color : Color
export var frame : int

onready var line_2d = $Line2D
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer

onready var icon = $Sprite/Icon
onready var extend_sprite = $Sprite/Extend

var type : String = "gui"
var dir : String = "forward"

onready var GUI = get_node("/root/Main/GUI")

func _ready():
	icon.set_visible(false)
	line_2d.default_color = line_color
	sprite.set_frame(frame)
	extend_sprite.set_visible(false)

func play(speed):
	extend_sprite.set_visible(false)
	dir = "forward"
	
	anim_player.playback_speed = speed
	anim_player.play("LineDropdown")

func play_reverse(speed):
	dir = "backward"
	
	anim_player.playback_speed = speed
	anim_player.play_backwards("LineDropdown")

func turn_into_gui():
	sprite.texture = load("res://assets/ui/gui_signs.png")
	type = "gui"

func turn_into_reminder():
	sprite.texture = load("res://assets/ui/tutorial_reminders.png")
	type = "reminder"

func turn_into_game_over(winning_team):
	sprite.set_frame(3)
	
	icon.set_visible(true)
	icon.set_frame(winning_team)

func _on_AnimationPlayer_animation_finished(_anim_name):
	var should_extend_sprite = (frame == 1 and type == 'reminder')
	if not should_extend_sprite: return
	
	var tw = GUI.tween
	var start = Vector2.ZERO
	var end = Vector2(0,350)
	if dir == "backward":
		var temp = end
		end = start
		start = temp
	
	extend_sprite.set_visible(true)
	tw.interpolate_property(extend_sprite, "position", 
		start, end, 1.0,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tw.start()
