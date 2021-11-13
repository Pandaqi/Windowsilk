extends Node


var bg_audio = null # TO DO
var bg_audio_player

var audio_preload = {
	
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

func create_audio_player(volume_alteration, bus : String = "FX", spatial : bool = false):
	var audio_player
	
	if spatial:
		audio_player = AudioStreamPlayer2D.new()
	else:
		audio_player = AudioStreamPlayer.new()
	
	audio_player.bus = bus
	audio_player.volume_db = volume_alteration
	audio_player.connect("finished", audio_player, "queue_free")
	audio_player.pause_mode = Node.PAUSE_MODE_PROCESS
	
	return audio_player

func play_static_sound(key, volume_alteration = 0, bus : String = "GUI"):
	if not audio_preload.has(key): return
	
	var audio_player = create_audio_player(volume_alteration, bus)

	add_child(audio_player)
	
	audio_player.stream = pick_audio(key)
	audio_player.pitch_scale = 1.0 + 0.075*(randf()-0.5)
	audio_player.play()
	
	return audio_player

func play_dynamic_sound(creator, key, volume_alteration = 0, bus : String = "FX"):
	if not audio_preload.has(key): return
	
	var audio_player = create_audio_player(volume_alteration, bus, true)

	audio_player.max_distance = 2000
	audio_player.set_position(creator.get_global_position())
	audio_player.pitch_scale = 1.0 + 0.075*(randf()-0.5)
	
	add_child(audio_player)
	
	audio_player.stream = pick_audio(key)
	audio_player.play()
	
	return audio_player
