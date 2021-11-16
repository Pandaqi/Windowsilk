extends Node2D

func _ready():
	$Timer.wait_time = $CPUParticles2D.lifetime
	$Timer.start()

func _on_Timer_timeout():
	self.queue_free()
