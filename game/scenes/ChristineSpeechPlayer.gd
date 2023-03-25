extends AudioStreamPlayer2D

onready var sounds_deal_no = [preload("res://resources/assets/sfx/christine_nodeal_1.wav"),preload("res://resources/assets/sfx/christine_nodeal_2.wav")]
onready var sounds_deal_yes = [preload("res://resources/assets/sfx/christine_yesdeal_1.wav"),preload("res://resources/assets/sfx/christine_yesdeal_2.wav"),preload("res://resources/assets/sfx/christine_yesdeal_3.wav"),preload("res://resources/assets/sfx/christine_yesdeal_4.wav")]
onready var sounds_cantcarry = [preload("res://resources/assets/sfx/christine_cantcarrymore_1.wav"),preload("res://resources/assets/sfx/christine_cantcarrymore_2.wav")]
var sound : AudioStreamSample

func play_random_nodeal():
	if playing:
		return
	var sound_index : int = randi() % 2
	sound = sounds_deal_no[sound_index] 
	sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	stream = sound 
	play() 


func play_random_yesdeal():
	if playing:
		return
	var sound_index : int = randi() % 4
	sound = sounds_deal_yes[sound_index] 
	sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	stream = sound 
	play() 


func play_random_cantcarry():
	if playing:
		return
	var sound_index : int = randi() % 2
	sound = sounds_cantcarry[sound_index] 
	sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	stream = sound 
	play() 
