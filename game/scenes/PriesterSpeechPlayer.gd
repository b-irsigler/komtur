extends AudioStreamPlayer2D

onready var sounds_healing = [preload("res://resources/assets/sfx/christine_nodeal_1.wav"),preload("res://resources/assets/sfx/christine_nodeal_2.wav")]
onready var sounds_horny = [preload("res://resources/assets/sfx/christine_yesdeal_1.wav"),preload("res://resources/assets/sfx/christine_yesdeal_2.wav"),preload("res://resources/assets/sfx/christine_yesdeal_3.wav"),preload("res://resources/assets/sfx/christine_yesdeal_4.wav")]
var sound : AudioStreamSample

func play_random_healing():
	if playing:
		return
	var sound_index : int = randi() % 2
	sound = sounds_healing[sound_index] 
	sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	stream = sound 
	play() 


func play_random_horny():
	if playing:
		return
	var sound_index : int = randi() % 2
	sound = sounds_horny[sound_index] 
	sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	stream = sound 
	play() 
