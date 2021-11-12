extends Node2D

export var line_color : Color
export var frame : int

onready var line_2d = $Line2D
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer

onready var icon = $Sprite/Icon

func _ready():
	icon.set_visible(false)
	line_2d.default_color = line_color
	sprite.set_frame(frame)

func play(speed):
	anim_player.playback_speed = speed
	anim_player.play("LineDropdown")

func play_reverse(speed):
	anim_player.playback_speed = speed
	anim_player.play_backwards("LineDropdown")

func turn_into_game_over(winning_team):
	sprite.set_frame(3)
	
	icon.set_visible(true)
	icon.set_frame(winning_team)
