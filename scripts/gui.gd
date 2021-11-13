extends CanvasLayer

var reminder_phase : bool = false
var paused : bool = false
var game_over : bool = false

onready var gui_signs = [$GUISign1, $GUISign2, $GUISign3]
var sign_counter = 0
var dir = 'down'

onready var game_over_timer = $GameOverTimer
var winning_team : int = -1
var shader_base_color = Color(18/255.0, 17/255.0, 33/255.0, 0.0)

onready var timer = $Timer
onready var bg = $BG
onready var tween = $Tween
onready var cutout = $Cutout
onready var message = $Message

const TIME_BETWEEN_SIGN_DROPS : float = 0.2
const ANIM_SPEED_DROP : float = 2.0

const TIME_BETWEEN_SIGN_HAULS : float = 0.1
const ANIM_SPEED_HAUL : float = 4.0

const BG_FADE_TIME : float = 0.5
const DELAY_BEFORE_GAME_OVER : float = 3.5

onready var players = get_node("/root/Main/Players")
onready var web = get_node("/root/Main/Web")

onready var pause_reminder = $PauseReminder
const PAUSE_REMINDER_FADE_DUR : float = 10.0

onready var reminder_timer = $ReminderTimer
const RULE_REMINDER_DUR : float = 10.0
const RULE_REMINDER_DUR_LENGTHEN : float = 4.0

func _ready():
	bg.color = Color(0,0,0,0)
	cutout.material = cutout.material.duplicate(true)
	cutout.set_visible(false)
	message.set_visible(false)

	show_reminders()

#
# Polling input
#
func _input(ev):
	var res = check_reminder_input(ev)
	if res: return
	
	res = check_regular_input(ev)
	if res: return
	
	res = check_pause_input(ev)
	if res: return
	
	check_game_over_input(ev)

func check_reminder_input(ev):
	if not reminder_phase: return false
	if not ev.is_action_released("pause"): return false
	force_hide_reminders()
	return true

func check_regular_input(ev):
	if paused or game_over or reminder_phase: return false
	if not ev.is_action_released("pause"): return false
	pause()
	return true

func check_pause_input(ev):
	if (not paused) or game_over or reminder_phase: return false
	if ev.is_action_released("exit"):
		exit()
		return true
	elif ev.is_action_released("restart"):
		restart()
		return true
	elif ev.is_action_released("unpause"):
		unpause()
		return true

func check_game_over_input(ev):
	if not game_over: return false
	if ev.is_action_released("exit"):
		exit()
		return true
	elif ev.is_action_released("restart"):
		restart()
		return true

#
# Rule reminders
#
func show_reminders():
	pause_reminder.get_node("Sprite").set_frame(1)
	
	get_tree().paused = true
	reminder_phase = true
	
	for i in range(gui_signs.size()):
		gui_signs[i].turn_into_reminder()
	
	play_dropdown_animation()
	
	reminder_timer.wait_time = RULE_REMINDER_DUR
	reminder_timer.start()

func _on_ReminderTimer_timeout():
	play_pullup_animation()

func force_hide_reminders():
	reminder_timer.stop()
	play_pullup_animation()

func hide_reminders():
	get_tree().paused = false
	reminder_phase = false
	start_fading_pause_reminder()

func start_fading_pause_reminder():
	pause_reminder.get_node("Sprite").set_frame(0)
	
	tween.interpolate_property(pause_reminder, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), PAUSE_REMINDER_FADE_DUR,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	

#
# Animating the reveals of the boxes (and line wobbling)
#
func play_dropdown_animation():
	fade_in_bg()
	
	dir = 'down'
	sign_counter = 0
	drop_next_sign()

func play_pullup_animation():
	fade_out_bg()
	
	dir = 'up'
	sign_counter = gui_signs.size() - 1
	haul_next_sign()

func on_dropdown_finished():
	pass

func on_pullup_finished():
	if reminder_phase:
		hide_reminders()
	elif paused:
		finish_unpause()

func fade_in_bg():
	tween.interpolate_property(bg, "color",
		Color(1,1,1,0), Color(1,1,1,125/255.0), BG_FADE_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func fade_out_bg():
	tween.interpolate_property(bg, "color",
		bg.color, Color(1,1,1,0), BG_FADE_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func drop_next_sign():
	if sign_counter >= gui_signs.size(): 
		on_dropdown_finished()
		return
	
	var gs = gui_signs[sign_counter]
	gs.play(ANIM_SPEED_DROP)
	
	timer.wait_time = TIME_BETWEEN_SIGN_DROPS*RULE_REMINDER_DUR_LENGTHEN
	
	if sign_counter == 1 and reminder_phase:
		timer.wait_time *= 2.0
	
	timer.start()
	
	sign_counter += 1

func haul_next_sign():
	if sign_counter < 0: 
		on_pullup_finished()
		return
	
	var gs = gui_signs[sign_counter]
	gs.play_reverse(ANIM_SPEED_HAUL)
	
	timer.wait_time = TIME_BETWEEN_SIGN_HAULS
	timer.start()
	
	sign_counter -= 1

func _on_Timer_timeout():
	if dir == 'up': haul_next_sign()
	elif dir == 'down': drop_next_sign()

#
# Game over
#
func activate_game_over(team):
	winning_team = team
	
	game_over_timer.wait_time = DELAY_BEFORE_GAME_OVER
	game_over_timer.start()
	
	cutout.set_visible(true)
	tween.interpolate_property(cutout.material, "shader_param/radius",
		0, 90.0, 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	
	var modulate_base_color = shader_base_color
	modulate_base_color.a = (180/255.0)
	
	tween.interpolate_property(cutout.material, "shader_param/base_color",
		shader_base_color, modulate_base_color, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	var message_scale_dur = 0.5
	
	message.set_scale(Vector2.ZERO)
	message.set_visible(true)
	
	tween.interpolate_property(message, "scale",
		Vector2.ZERO, Vector2(1,1), message_scale_dur,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	
	tween.interpolate_property(message, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), DELAY_BEFORE_GAME_OVER-0.5-message_scale_dur,
		Tween.TRANS_LINEAR, Tween.EASE_OUT,
		message_scale_dur)
	
	tween.start()

func _on_GameOverTimer_timeout():
	gui_signs[1].turn_into_game_over(winning_team)
	
	game_over = true
	
	for i in range(gui_signs.size()):
		gui_signs[i].turn_into_gui()
	
	play_dropdown_animation()

func _physics_process(_dt):
	if winning_team < 0: return
	
	var team = players.get_players_in_team(winning_team)
	var counter = 0
	for p in team:
		var screen_pos = p.get_global_transform_with_canvas().origin
		var shader_key = "p" + str(counter+1)
		
		cutout.material.set_shader_param(shader_key, screen_pos)
		counter += 1
	
	var home_base = web.home_bases[winning_team]
	var pos = home_base.get_global_transform_with_canvas().origin
	cutout.material.set_shader_param("home_base", pos)

#
# Pausing/Unpausing
#
func pause():
	get_tree().paused = true
	paused = true
	
	for i in range(gui_signs.size()):
		gui_signs[i].turn_into_gui()
	play_dropdown_animation()

func unpause():
	play_pullup_animation()

func finish_unpause():
	get_tree().paused = false
	paused = false

#
# Remaining scene navigation
#
func exit():
	get_tree().paused = false
	Global.back_to_menu()

func restart():
	get_tree().paused = false
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
