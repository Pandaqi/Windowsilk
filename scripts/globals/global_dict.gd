extends Node

var silk_types = {
	"regular": { "frame": 0, "color": Color(1,1,1) },
	"speedy": { "frame": 1, "color": Color(0,1,0) }
}

# All parameters are FALSE by default (this means simplified code and consistency)
# Non-boolean parameters, if omitted are just set to the basic value

# frame => the frame in the spritesheet
# points => points rewarded for eating
# move => type (def=web), speed, flee, chase, forbid_backtrack
# trail => what trail (silk type) it leaves; null means no trail
var entities = {
	"tiny_spider": { 
		"frame": 0, 
		"points": 1,
		"trail": "speedy",
		"move": { 
			"speed": 40,
		} 
	},
	
	"fly": {
		"frame": 1,
		"points": 1,
		"trail": null,
		"move": {
			"type": "flying",
		}
	}
	
	
}
