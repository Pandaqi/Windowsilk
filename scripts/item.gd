extends Area2D

var type : String = ""
var on_web : bool = false

func set_on_web(val):
	on_web = val

func set_type(tp):
	type = tp

func _on_Item_body_entered(body):
	body.m.collector.collect(self)
