extends Node


var bg_audio = null # TO DO
var bg_audio_player

var audio_preload = {
	# win/lose (points)
	"receive_points": preload("res://assets/audio/receive_points.ogg"),
	"store_points": preload("res://assets/audio/store_points.ogg"),
	"win_game": preload("res://assets/audio/win_game.ogg"),
	
	"lose_points": preload("res://assets/audio/lose_points.ogg"),
	"death": preload("res://assets/audio/death.ogg"),
	
	# movement
	"move_legs_constant": preload("res://assets/audio/move_legs.ogg"),
	"move_legs": [
		preload("res://assets/audio/move_legs_1.ogg"),
		preload("res://assets/audio/move_legs_2.ogg"),
		preload("res://assets/audio/move_legs_3.ogg")
	],
	"move_wings": [
		preload("res://assets/audio/move_wings_1.ogg"),
		preload("res://assets/audio/move_wings_2.ogg"),
		preload("res://assets/audio/move_wings_3.ogg"),
		preload("res://assets/audio/move_wings_4.ogg"),
		preload("res://assets/audio/move_wings_5.ogg"),
		preload("res://assets/audio/move_wings_6.ogg"),
		preload("res://assets/audio/move_wings_7.ogg")
	],
	"move_worm": preload("res://assets/audio/move_worm.ogg"),
	
	# jumping
	"whoosh": [
		preload("res://assets/audio/whoosh_1.ogg"),
		preload("res://assets/audio/whoosh_2.ogg"),
		preload("res://assets/audio/whoosh_3.ogg"),
	],
	
	# specialties
	"noisemaker": preload("res://assets/audio/noisemaker.ogg"),
	"attractor": preload("res://assets/audio/attractor.ogg"),
	"poison": preload("res://assets/audio/poison.ogg"),
	
	# web (creation/destruction/stuck/paint) (TO DO)
	"web_create": preload("res://assets/audio/web_create.ogg"),
	"web_stuck": preload("res://assets/audio/web_stuck.ogg"),
	"web_destroy": preload("res://assets/audio/web_destroy.ogg"),
	"web_paint": preload("res://assets/audio/web_paint.ogg"),
	
	# eating
	"munch": [
		preload("res://assets/audio/munch_1.ogg"),
		preload("res://assets/audio/munch_2.ogg"),
		preload("res://assets/audio/munch_3.ogg"),
		preload("res://assets/audio/munch_4.ogg"),
		preload("res://assets/audio/munch_5.ogg"),
		preload("res://assets/audio/munch_6.ogg"),
		preload("res://assets/audio/munch_7.ogg")
	],
	
	# arena-specific
	"water_splash": preload("res://assets/audio/water_splash.ogg"),
	"gust_of_wind": preload("res://assets/audio/gust_of_wind.ogg")
}

func _ready():
	create_background_stream()

func create_background_stream():
	bg_audio_player = AudioStreamPlayer.new()
	add_child(bg_audio_player)
	
	bg_audio_player.bus = "BG"
	bg_audio_player.stream = bg_audio
	bg_audio_player.play()
	
	bg_audio_player.pause_mode = Node.PAUSE_MODE_PROCESS

func pick_audio(key):
	var wanted_audio = audio_preload[key]
	if wanted_audio is Array: wanted_audio = wanted_audio[randi() % wanted_audio.size()]
	return wanted_audio

func create_audio_player(volume_alteration, bus : String = "FX", spatial : bool = false, destroy_when_done : bool = true):
	var audio_player
	
	if spatial:
		audio_player = AudioStreamPlayer2D.new()
	else:
		audio_player = AudioStreamPlayer.new()
	
	audio_player.bus = bus
	audio_player.volume_db = volume_alteration
	
	if destroy_when_done:
		audio_player.connect("finished", audio_player, "queue_free")
	#audio_player.pause_mode = Node.PAUSE_MODE_PROCESS
	
	return audio_player

func play_static_sound(key, volume_alteration = 0, bus : String = "GUI"):
	if not audio_preload.has(key): return
	
	var audio_player = create_audio_player(volume_alteration, bus)

	add_child(audio_player)
	
	audio_player.stream = pick_audio(key)
	audio_player.pitch_scale = 1.0 + 0.075*(randf()-0.5)
	audio_player.play()
	
	return audio_player

func play_dynamic_sound(creator, key, volume_alteration = 0, bus : String = "FX", destroy_when_done : bool = true):
	if not audio_preload.has(key): return
	
	var audio_player = create_audio_player(volume_alteration, bus, true, destroy_when_done)

	audio_player.max_distance = 2000
	audio_player.set_position(creator.get_global_position())
	audio_player.pitch_scale = 1.0 + 0.075*(randf()-0.5)
	
	add_child(audio_player)
	
	audio_player.stream = pick_audio(key)
	audio_player.play()
	
	return audio_player
