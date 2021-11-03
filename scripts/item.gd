extends Area2D

var type : String = ""

func set_type(tp):
	type = tp

func _on_Item_body_entered(body):
	body.m.collector.collect(self)
