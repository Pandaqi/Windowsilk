extends Area2D

var num_overlapping_bounds = 0

func out_of_bounds():
	return (num_overlapping_bounds > 0)

func _on_GeneralArea_body_entered(body):
	if body.is_in_group("Bounds"): num_overlapping_bounds += 1

func _on_GeneralArea_body_exited(body):
	if body.is_in_group("Bounds"): num_overlapping_bounds -= 1
