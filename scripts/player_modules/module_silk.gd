extends Node2D

const MAX_SILK : int = 100
const STARTING_SILK : int = 5

var num : int = 0

onready var label_container = $LabelContainer
onready var label = $LabelContainer/Label

onready var body = get_parent()

func _ready():
	change(STARTING_SILK)

func change(val):
	num = clamp(num + val, 0.0, MAX_SILK)
	
	label.set_text(str(num))

func _physics_process(dt):
	label_container.set_rotation(-body.rotation)

func is_empty():
	return (num <= 0)

func count():
	return num
