extends CPUParticles2D

onready var time_created = Time.get_ticks_msec()

func _process(delta):
	if Time.get_ticks_msec() - time_created > 5000:
		queue_free()
